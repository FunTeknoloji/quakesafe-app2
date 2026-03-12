import 'package:supabase_flutter/supabase_flutter.dart';

class DisasterPlanService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getPlan() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('disaster_plans_quakesafe')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response?['plan_data'];
    } catch (e) {
      return null;
    }
  }

  Future<void> savePlan(Map<String, dynamic> planData) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('disaster_plans_quakesafe').upsert({
      'user_id': userId,
      'plan_data': planData,
    });
  }
}
