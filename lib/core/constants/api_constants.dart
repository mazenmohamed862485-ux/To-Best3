// lib/core/constants/api_constants.dart

/// API action constants — must match Code.gs on the server
class ApiActions {
  ApiActions._();

  // Auth
  static const String login           = 'LOGIN';
  static const String register        = 'REGISTER';
  static const String forgotPassword  = 'FORGOT_PASSWORD';
  static const String resetPassword   = 'RESET_PASSWORD';
  static const String changePassword  = 'CHANGE_PASSWORD';
  static const String guestLogin      = 'GUEST_LOGIN';
  static const String ping            = 'PING';
  static const String checkBan        = 'CHECK_BAN';
  static const String checkVersion    = 'CHECK_VERSION';

  // Data
  static const String fetchUserData   = 'FETCH_USER_DATA';
  static const String fetchAllUsers   = 'FETCH_ALL_USERS';
  static const String fullSyncPull    = 'FULL_SYNC_PULL';
  static const String updateProfile   = 'UPDATE_PROFILE';
  static const String updateUserSheet = 'UPDATE_USER_SHEET';
  static const String saveWorkoutLog  = 'SAVE_WORKOUT_LOG';
  static const String saveMeals       = 'SAVE_MEALS';
  static const String saveWater       = 'SAVE_WATER';
  static const String saveAttendance  = 'SAVE_ATTENDANCE';
  static const String saveMeasurement = 'SAVE_MEASUREMENT';
  static const String saveProfilePic  = 'SAVE_PROFILE_PIC';
  static const String setting         = 'SETTING';

  // Chat
  static const String fetchMsgs       = 'FETCH_MSGS';
  static const String sendMsg         = 'SEND_MSG';
  static const String deleteMsg       = 'DELETE_MSG';
  static const String editMsg         = 'EDIT_MSG';
  static const String pinMsg          = 'PIN_MSG';
  static const String getPinned       = 'GET_PINNED';

  // Admin
  static const String adminUpdateUser = 'ADMIN_UPDATE_USER';
  static const String adminApprove    = 'ADMIN_APPROVE';
  static const String adminDeleteUser = 'ADMIN_DELETE_USER';
  static const String approveProgram  = 'APPROVE_PROGRAM';
  static const String forceLogoutUser = 'FORCE_LOGOUT_USER';
  static const String forceLogoutAll  = 'FORCE_LOGOUT_ALL';

  // Subscription
  static const String subRequest      = 'SUB_REQUEST';
  static const String getSubRequests  = 'GET_SUB_REQUESTS';
  static const String updateSubReq    = 'UPDATE_SUB_REQUEST';

  // Promo
  static const String promoCheck      = 'PROMO_CHECK';
  static const String promoCreate     = 'PROMO_CREATE';
  static const String promoList       = 'PROMO_LIST';
  static const String promoDelete     = 'PROMO_DELETE';

  // Guest
  static const String guestCreate     = 'GUEST_CREATE';
  static const String guestList       = 'GUEST_LIST';
  static const String guestDelete     = 'GUEST_DELETE';

  // Ban
  static const String banIdentity     = 'BAN_IDENTITY';
  static const String unbanIdentity   = 'UNBAN_IDENTITY';
  static const String listBanned      = 'LIST_BANNED';

  // Referral
  static const String getReferralStats = 'GET_REFERRAL_STATS';
}
