//   const  BASE_URL = BuildConfig.BASE_URL
//const baseUrl = "http://10.1.0.12:8045/";
//const baseUrl = "http://10.1.0.12:8084/";
const baseUrl = "http://182.160.105.228:8018/";

const baseUrlApi = "${baseUrl}api/";

class Endpoints {
  static const loginUrl = "${baseUrlApi}User/VerifryUserMobile";
  static const changePasswordUrl = "${baseUrlApi}secuirity/changepassword";
  static const saveApplicationFileAttachmentsUrl = "${baseUrlApi}Attachments/saveApplicationFileAttachments";

}
