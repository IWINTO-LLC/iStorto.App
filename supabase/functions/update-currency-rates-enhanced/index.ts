import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ExchangeRateProvider {
  name: string
  url: string
  apiKey?: string
  transform: (data: any) => Record<string, number>
}

const exchangeRateProviders: ExchangeRateProvider[] = [
  {
    name: 'exchangerate-api',
    url: 'https://api.exchangerate-api.com/v4/latest/USD',
    transform: (data) => data.rates
  },
  {
    name: 'fixer',
    url: 'https://api.fixer.io/latest',
    apiKey: Deno.env.get('FIXER_API_KEY'),
    transform: (data) => data.rates
  },
  {
    name: 'currencylayer',
    url: 'https://api.currencylayer.com/live',
    apiKey: Deno.env.get('CURRENCYLAYER_API_KEY'),
    transform: (data) => data.quotes
  }
]

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const startTime = Date.now()
  let updateId: string | null = null

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Log start of update
    const { data: logData } = await supabaseClient
      .from('currency_update_history')
      .insert({
        update_type: 'cron',
        source: 'edge_function',
        currencies_updated: 0,
        success: false,
        error_message: 'Update started'
      })
      .select('id')
      .single()

    updateId = logData?.id

    // Try to fetch rates from multiple providers
    const rates = await fetchRatesFromMultipleProviders()
    
    if (!rates || Object.keys(rates).length === 0) {
      throw new Error('Failed to fetch rates from any provider')
    }

    // Update currencies in database
    const updateResults = await updateCurrencyRates(supabaseClient, rates)

    // Log successful update
    const executionTime = Date.now() - startTime
    await supabaseClient
      .from('currency_update_history')
      .update({
        currencies_updated: updateResults.updatedCount,
        success: true,
        execution_time_ms: executionTime
      })
      .eq('id', updateId)

    return new Response(
      JSON.stringify({
        success: true,
        message: `Updated ${updateResults.updatedCount} currencies`,
        timestamp: new Date().toISOString(),
        execution_time_ms: executionTime,
        rates_count: Object.keys(rates).length,
        update_id: updateId
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Error updating currency rates:', error)
    
    const executionTime = Date.now() - startTime
    
    // Log failed update
    if (updateId) {
      try {
        await supabaseClient
          .from('currency_update_history')
          .update({
            success: false,
            error_message: error.message,
            execution_time_ms: executionTime
          })
          .eq('id', updateId)
      } catch (logError) {
        console.error('Failed to log error:', logError)
      }
    }
    
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
        timestamp: new Date().toISOString(),
        execution_time_ms: executionTime,
        update_id: updateId
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})

async function fetchRatesFromMultipleProviders(): Promise<Record<string, number> | null> {
  for (const provider of exchangeRateProviders) {
    try {
      console.log(`Trying provider: ${provider.name}`)
      
      let url = provider.url
      if (provider.apiKey) {
        url += `?access_key=${provider.apiKey}`
      }
      
      const response = await fetch(url, {
        headers: {
          'User-Agent': 'Supabase-Currency-Update/1.0'
        }
      })
      
      if (!response.ok) {
        console.error(`${provider.name} failed with status: ${response.status}`)
        continue
      }
      
      const data = await response.json()
      const rates = provider.transform(data)
      
      if (rates && Object.keys(rates).length > 0) {
        console.log(`Successfully fetched rates from ${provider.name}`)
        return rates
      }
      
    } catch (error) {
      console.error(`Error with ${provider.name}:`, error)
      continue
    }
  }
  
  return null
}

async function updateCurrencyRates(supabaseClient: any, rates: Record<string, number>) {
  const updates = []
  let updatedCount = 0
  const errors = []

  // Get existing currencies from database
  const { data: existingCurrencies } = await supabaseClient
    .from('currencies')
    .select('iso')

  const existingISOs = new Set(existingCurrencies?.map(c => c.iso) || [])

  for (const [iso, rate] of Object.entries(rates)) {
    // Only update currencies that exist in our database
    if (!existingISOs.has(iso)) {
      continue
    }

    try {
      const { error } = await supabaseClient
        .from('currencies')
        .update({
          usd_to_coin_exchange_rate: rate,
          updated_at: new Date().toISOString()
        })
        .eq('iso', iso)

      if (error) {
        console.error(`Error updating ${iso}:`, error)
        errors.push({ iso, error: error.message })
      } else {
        updatedCount++
        updates.push({ iso, rate, status: 'success' })
      }
    } catch (error) {
      console.error(`Exception updating ${iso}:`, error)
      errors.push({ iso, error: error.message })
    }
  }

  return { updatedCount, updates, errors }
}


