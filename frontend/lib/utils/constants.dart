class ApiConstants {
  // Cambia localhost por tu IP real cuando pruebes en el celular
  // static const String baseUrl = 'http://10.0.2.2:8000/api/'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000/api/'; // iOS simulator
  // static const String baseUrl = 'http://192.168.1.45:8000/api/'; // Tu IP real
  static const String baseUrl = 'https://sensoria-api.onrender.com/api/'; // Tu URL de Render sin errores
  
  // Auth
  static const String login = '${baseUrl}auth/login/';
  static const String refresh = '${baseUrl}auth/refresh/'; // 👈 Se quitó la barra antes de auth
  
  // Users
  static const String register = '${baseUrl}users/register/'; // 👈 Se quitó la barra antes de users
  static const String profile = '${baseUrl}users/profile/';
  static const String points = '${baseUrl}users/points/';
  
  // Recycling
  static const String residuos = '${baseUrl}recycling/residuos/';
  static const String scan = '${baseUrl}recycling/scan/';
  static const String history = '${baseUrl}recycling/history/';
  static const String stats = '${baseUrl}recycling/stats/';
  static const String sync = '${baseUrl}recycling/sync/';
  
  // Gamification
  static const String challenges = '${baseUrl}gamification/challenges/';
  static const String dailyMissions = '${baseUrl}gamification/daily-missions/';
  static const String achievements = '${baseUrl}gamification/achievements/';
  static const String leaderboard = '${baseUrl}gamification/leaderboard/';
  static const String myDailyMissions = '${baseUrl}gamification/my-daily-missions/';
  
  // Marketplace
  static const String rewards = '${baseUrl}marketplace/rewards/';
  static const String redeem = '${baseUrl}marketplace/redeem/';
  static const String canjesHistory = '${baseUrl}marketplace/history/';
  
  // Chatbot
  static const String chatbotSend = '${baseUrl}chatbot/send/';
  static const String chatbotTips = '${baseUrl}chatbot/tips/';

  // Admin
  static const String createBin = '${baseUrl}admin/bins/create/';
  static const String scanQR = '${baseUrl}admin/bins/scan/';
  static const String updateBinStatus = '${baseUrl}admin/bins/status/';
  
  static const String passwordReset = '${baseUrl}users/password-reset/';
  static const String passwordResetConfirm = '${baseUrl}users/password-reset-confirm/';

  static const String myAchievements = '${baseUrl}gamification/my-achievements/';

  static const String featuredRewards = '${baseUrl}marketplace/rewards/featured/';
}