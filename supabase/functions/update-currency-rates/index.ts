// import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
// import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// const corsHeaders = {
//   'Access-Control-Allow-Origin': '*',
//   'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
// }

// serve(async (req) => {
//   // Handle CORS preflight requests
//   if (req.method === 'OPTIONS') {
//     return new Response('ok', { headers: corsHeaders })
//   }

//   try {
//     // Initialize Supabase client
//     const supabaseClient = createClient(
//       Deno.env.get('SUPABASE_URL') ?? '',
//       Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
//     )

//     // Get exchange rates from external API
//     const exchangeRates = await fetchExchangeRates()
    
//     if (!exchangeRates) {
//       throw new Error('Failed to fetch exchange rates')
//     }

//     // Update currencies in database
//     const updateResults = await updateCurrencyRates(supabaseClient, exchangeRates)

//     return new Response(
//       JSON.stringify({
//         success: true,
//         message: `Updated ${updateResults.updatedCount} currencies`,
//         timestamp: new Date().toISOString(),
//         rates: exchangeRates
//       }),
//       {
//         headers: { ...corsHeaders, 'Content-Type': 'application/json' },
//         status: 200,
//       }
//     )

//   } catch (error) {
//     console.error('Error updating currency rates:', error)
    
//     return new Response(
//       JSON.stringify({
//         success: false,
//         error: error.message,
//         timestamp: new Date().toISOString()
//       }),
//       {
//         headers: { ...corsHeaders, 'Content-Type': 'application/json' },
//         status: 500,
//       }
//     )
//   }
// })

// // Fetch exchange rates from external API
// async function fetchExchangeRates() {
//   try {
//     // Using ExchangeRate-API (free tier: 1500 requests/month)
//     const response = await fetch('https://api.exchangerate-api.com/v4/latest/USD')
    
//     if (!response.ok) {
//       throw new Error(`HTTP error! status: ${response.status}`)
//     }
    
//     const data = await response.json()
    
//     // Convert to our format
//     const rates = {}
//     for (const [currency, rate] of Object.entries(data.rates)) {
//       rates[currency] = rate
//     }
    
//     return rates
//   } catch (error) {
//     console.error('Error fetching exchange rates:', error)
    
//     // Fallback to another API
//     try {
//       const fallbackResponse = await fetch('https://api.fixer.io/latest?access_key=YOUR_API_KEY&base=USD')
//       const fallbackData = await fallbackResponse.json()
      
//       const rates = {}
//       for (const [currency, rate] of Object.entries(fallbackData.rates)) {
//         rates[currency] = rate
//       }
      
//       return rates
//     } catch (fallbackError) {
//       console.error('Fallback API also failed:', fallbackError)
//       return null
//     }
//   }
// }

// // Update currency rates in database
// async function updateCurrencyRates(supabaseClient: any, rates: any) {
//   const updates = []
//   let updatedCount = 0

//   for (const [iso, rate] of Object.entries(rates)) {
//     try {
//       const { error } = await supabaseClient
//         .from('currencies')
//         .update({
//           usd_to_coin_exchange_rate: rate,
//           updated_at: new Date().toISOString()
//         })
//         .eq('iso', iso)

//       if (error) {
//         console.error(`Error updating ${iso}:`, error)
//       } else {
//         updatedCount++
//         updates.push({ iso, rate, status: 'success' })
//       }
//     } catch (error) {
//       console.error(`Exception updating ${iso}:`, error)
//       updates.push({ iso, rate, status: 'error', error: error.message })
//     }
//   }

//   return { updatedCount, updates }
// }


