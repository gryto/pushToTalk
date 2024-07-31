class ApiService {
  static String version = "1.0.1";
  static String uri = "paket7.kejaksaan.info";
  static String server = "http://$uri";
  static String endPoint = "$server:3007";
  // static String folder = "https://$uri/upload/mirror/user_profile";

  static String folder = endPoint;
  static String folderNotif = "$endPoint/storage/notif_img";
  static String imgDefault ="https://rinovin.kejaksaan.info/assets/images/users/user-dummy.jpg";
  static String setLogin = "$endPoint/api/login";
  static String detailUser = "$endPoint/api/getuser";
  static String editUser = "$endPoint/api/edituser";
  static String listUser = "$endPoint/api/listuser";
  static String listContact = "$endPoint/api/indexagen";
  static String getIdContact = "$endPoint/api/getagen";
  static String addContact = "$endPoint/api/addagen";


  static String sosCreate = "$endPoint/api/addsos";
  static String sosHistory = "$endPoint/api/historysos";
  static String sosDetail = "$endPoint/api/getsos";
  static String sosHandle = "$endPoint/api/handlesos";
  static String sosFinish = "$endPoint/api/finishsos";
  static String sosAll = "$endPoint/api/getallsos";

  static String chatRoom = "$endPoint/api/chatstore";
  static String chatPartner = "$endPoint/api/chatpartner";
  static String chatHistory = "$endPoint/api/chathistory";




}
