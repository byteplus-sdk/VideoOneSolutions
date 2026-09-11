// number of local avatars
const AVATAR_NUMBER = 20;
// get avatar asset path
String getAvatarUrl(String userId) {
  final intUserID = int.parse(userId, radix: 10);
  int avatarId = intUserID % AVATAR_NUMBER;
  final avatarIdStr = avatarId.toString().padLeft(2, '0');
  return 'assets/minidrama/avatars/avatar$avatarIdStr.png';
}
