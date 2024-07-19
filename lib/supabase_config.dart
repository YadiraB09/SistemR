import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://kyyjffdmnhdhxncjycww.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5eWpmZmRtbmhkaHhuY2p5Y3d3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTg3MjY5MzUsImV4cCI6MjAzNDMwMjkzNX0.Kdx8QxtySP7rT3CMxouKh_U807oloQ1CPwbn0u4-AK0',
  );
}
