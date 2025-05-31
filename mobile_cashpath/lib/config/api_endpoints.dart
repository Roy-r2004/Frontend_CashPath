class ApiEndpoints {
  static const String BASE_URL = "http://127.0.0.1:8000/api"; // Update this to your actual backend URL

  // ✅ Authentication Endpoints
  static const String register = "$BASE_URL/register";
  static const String login = "$BASE_URL/login";
  static const String userProfile = "$BASE_URL/user-profile";
  static const String updateProfile = "$BASE_URL/update-profile";
  static const String updatePassword = "$BASE_URL/update-password";
  static const String logout = "$BASE_URL/logout";

  // ✅ Account Endpoints
  static const String accounts = "$BASE_URL/accounts";
  static String accountDetails(String id) => "$BASE_URL/accounts/$id";
  static const String totalBalance = "$BASE_URL/accounts/balance/total";
  static String setDefaultAccount(String id) => "$BASE_URL/accounts/$id/set-default";
  static String createAccount = "$BASE_URL/accounts";
  static String updateAccount(String id) => "$BASE_URL/accounts/$id";
  static String deleteAccount(String id) => "$BASE_URL/accounts/$id";

  // ✅ Transactions Endpoints
  static const String transactions = "$BASE_URL/transactions";
  static String transactionDetails(String id) => "$BASE_URL/transactions/$id";
  static const String transactionSummary = "$BASE_URL/user/transactions/summary";
  static String yearlyTransactions(int year) => "$BASE_URL/transactions/year/$year";
  static String monthlyTransactions(int year, int month) => "$BASE_URL/transactions/month/$year/$month";
  static String dailyTransactions(int year, int month, int day) => "$BASE_URL/transactions/day/$year/$month/$day";
  static String calendarTransactions(int year, int month) => "$BASE_URL/transactions/calendar/$year/$month";
  static String searchTransactions(String keyword) => "$BASE_URL/transactions/search?keyword=$keyword";

  // ✅ Statistics Endpoint (Newly Added)
  static String transactionStatistics(int year, int month) =>
      "$BASE_URL/transactions/statistics?year=$year&month=$month";


  // ✅ Categories Endpoints
  static const String categories = "$BASE_URL/categories";
  static String categoryDetails(String id) => "$BASE_URL/categories/$id";
  static String subCategories(String id) => "$BASE_URL/categories/$id/subcategories";

  // ✅ Budget Endpoints
  static const String budgets = "$BASE_URL/budgets";
  static const String createBudget = "$BASE_URL/budgets/create";
  static const String autoAllocateBudget = "$BASE_URL/budgets/auto-allocate";
  static String updateBudget(String id) => "$BASE_URL/budgets/$id";
  static String deleteBudget(String id) => "$BASE_URL/budgets/$id";
  static const String budgetSummary = "$BASE_URL/budgets/summary";

}


