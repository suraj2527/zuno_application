// ignore_for_file: file_names

class DatingProfile {
  final String id;
  final String userName;
  final String age;
  final String bio;
  final String location;
  final List<String> interests;
  final String profileImageUrl; 
  final bool isActiveNow;
  final String distance;
  final List<String> imageUrls;

  final String? gender;
  final String? lookingFor;

  DatingProfile({
    required this.id,
    required this.userName,
    required this.age,
    required this.bio,
    required this.location,
    required this.interests,
    required this.profileImageUrl,
    required this.isActiveNow,
    required this.distance,
    required this.imageUrls,
    this.gender,
    this.lookingFor,
  });

  /// ✅ Helpful for future profile updates
  DatingProfile copyWith({
    String? id,
    String? userName,
    String? age,
    String? bio,
    String? location,
    List<String>? interests,
    String? profileImageUrl,
    bool? isActiveNow,
    String? distance,
    List<String>? imageUrls,
    String? gender,
    String? lookingFor,
  }) {
    return DatingProfile(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActiveNow: isActiveNow ?? this.isActiveNow,
      distance: distance ?? this.distance,
      imageUrls: imageUrls ?? this.imageUrls,
      gender: gender ?? this.gender,
      lookingFor: lookingFor ?? this.lookingFor,
    );
  }
}