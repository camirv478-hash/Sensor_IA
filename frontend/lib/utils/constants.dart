class ApiConstants {
  // Cambia localhost por tu IP real cuando pruebes en el celular
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS simulator
  // static const String baseUrl = 'http://192.168.1.X:8000/api'; // Dispositivo real
  static const String baseUrl = 'http://192.168.1.42:8000/api'; // Tu IP real
  
  // Auth
  static const String login = '$baseUrl/auth/login/';
  static const String refresh = '$baseUrl/auth/refresh/';
  
  // Users
  static const String register = '$baseUrl/users/register/';
  static const String profile = '$baseUrl/users/profile/';
  static const String points = '$baseUrl/users/points/';
  
  // Recycling
  static const String residuos = '$baseUrl/recycling/residuos/';
  static const String scan = '$baseUrl/recycling/scan/';
  static const String history = '$baseUrl/recycling/history/';
  static const String stats = '$baseUrl/recycling/stats/';
  static const String sync = '$baseUrl/recycling/sync/';
  
  // Gamification
  static const String challenges = '$baseUrl/gamification/challenges/';
  static const String dailyMissions = '$baseUrl/gamification/daily-missions/';
  static const String achievements = '$baseUrl/gamification/achievements/';
  static const String leaderboard = '$baseUrl/gamification/leaderboard/';
  
  // Marketplace
  static const String rewards = '$baseUrl/marketplace/rewards/';
  static const String redeem = '$baseUrl/marketplace/redeem/';
  static const String canjesHistory = '$baseUrl/marketplace/history/';
  
  // Chatbot
  static const String chatbotSend = '$baseUrl/chatbot/send/';
  static const String chatbotTips = '$baseUrl/chatbot/tips/';
}