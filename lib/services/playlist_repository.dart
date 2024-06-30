abstract class PlaylistRepository{
  Future<List<Map<String,String>>> fetchMyPlaylist();
}

class MyPlaylist extends PlaylistRepository{
  @override
  Future<List<Map<String, String>>> fetchMyPlaylist() async{
    const song1 =
        'https://media-vip.my-pishvaz.com/musicfa/tagdl/ali/Behnam%20Bani%20-%202ta%20Dele%20Ashegh%20(320).mp3?st=cej_8MLrkmv_TKOImCvjpA&e=1701273730';
    const song2 =
        'https://dl.naslmusic.ir/music/1401/01/Shadmehr%20Aghili%20-%20Bi%20Ehsas%20(320-Naslemusic).mp3';
    const song3 =
        'https://dl.rozmusic.com/Music/1402/07/11/Ali%20Yasini%20-%20Mirese%20Khabara.mp3';
    const song4 =
        'https://media-vip.my-pishvaz.com/musicfa/tagdl/downloads/Garsha%20Rezaei%20-%20Darya%20Nemiram%20(320).mp3?st=cMGpGFHyxNMltyyaDZVzxQ&e=1701522543';
    return [
      {
        'id': '0',
        'title':'Dota Del Ashegh',
        'artist':'Behnam Bani',
        'artUri':'https://www.ganja2music.com/Image/Post/12.2021/Behnam%20Bani%20-%20Dota%20Dele%20Ashegh.jpg',
        'url': song1,
      },
      {
        'id': '1',
        'title':'Bi Ehsas',
        'artist':'Shadmehr Aghili',
        'artUri':'https://www.mybia2music.com/assets/thumbs/114637987_500.jpg',
        'url':song2,
      },
      {
        'id': '2',
        'title':'Mirese Khabara',
        'artist':'Ali Yasini',
        'artUri':'https://www.mybia2music.com/assets/thumbs/114657807_500.jpg',
        'url':song3,
      },
      {
        'id': '3',
        'title':'Darya Nemiram',
        'artist':'Garsha Rezaei',
        'artUri':'https://www.ganja2music.com/Image/Post/10.2019/Garsha%20Rezaei%20-%20Darya%20Nemiram.jpg',
        'url':song4,
      },
    ];
  }

}