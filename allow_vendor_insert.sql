-- السماح للمستخدمين بإدراج بيانات في جدول vendors (حتى لو كان فارغ)

-- حذف السياسات الموجودة إذا كانت موجودة
DROP POLICY IF EXISTS "Users can view their own vendor" ON vendors;
DROP POLICY IF EXISTS "Users can insert their own vendor" ON vendors;
DROP POLICY IF EXISTS "Users can update their own vendor" ON vendors;
DROP POLICY IF EXISTS "Users can delete their own vendor" ON vendors;
DROP POLICY IF EXISTS "Authenticated users can insert vendors" ON vendors;

-- تفعيل RLS على جدول vendors
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;

-- سياسة الإدراج - السماح للمستخدمين المسجلين بإدراج vendor جديد
CREATE POLICY "Authenticated users can insert vendors" ON vendors
FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- سياسة القراءة - المستخدمون يمكنهم رؤية vendor الخاص بهم
CREATE POLICY "Users can view their own vendor" ON vendors
FOR SELECT USING (auth.uid() = user_id);

-- سياسة التحديث - المستخدمون يمكنهم تحديث vendor الخاص بهم
CREATE POLICY "Users can update their own vendor" ON vendors
FOR UPDATE USING (auth.uid() = user_id);

-- سياسة الحذف - المستخدمون يمكنهم حذف vendor الخاص بهم
CREATE POLICY "Users can delete their own vendor" ON vendors
FOR DELETE USING (auth.uid() = user_id);

-- سياسة إضافية للقراءة العامة (اختيارية - لعرض vendors للجميع)
-- CREATE POLICY "Public can view active vendors" ON vendors
-- FOR SELECT USING (organization_activated = true);
