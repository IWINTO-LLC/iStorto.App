class SocialLink {
  // روابط منصات التواصل
  final String facebook;
  final String x;
  final String instagram;
  final String website;
  final String linkedin;
  final String whatsapp;
  final String tiktok;
  final String youtube;
  final String location;

  // قائمة أرقام الهواتف
  final List<String> phones;

  // حالاتها (إظهار أو لا)
  final bool visibleFacebook;
  final bool visibleX;
  final bool visibleInstagram;
  final bool visibleWebsite;
  final bool visibleLinkedin;
  final bool visibleWhatsapp;
  final bool visibleTiktok;
  final bool visibleYoutube;
  final bool visiblePhones;

  const SocialLink({
    this.facebook = '',
    this.x = '',
    this.instagram = '',
    this.website = '',
    this.linkedin = '',
    this.whatsapp = '',
    this.tiktok = '',
    this.youtube = '',
    this.location = '',
    this.phones = const [],
    this.visibleFacebook = true,
    this.visibleX = true,
    this.visibleInstagram = true,
    this.visibleWebsite = true,
    this.visibleLinkedin = true,
    this.visibleWhatsapp = true,
    this.visibleTiktok = true,
    this.visibleYoutube = true,
    this.visiblePhones = true,
  });

  factory SocialLink.fromJson(Map<String, dynamic> json) => SocialLink(
        facebook: json['facebook'] ?? '',
        x: json['x'] ?? '',
        instagram: json['instagram'] ?? '',
        website: json['website'] ?? '',
        linkedin: json['linkedin'] ?? '',
        whatsapp: json['whatsapp'] ?? '',
        tiktok: json['tiktok'] ?? '',
        youtube: json['youtube'] ?? '',
        location: json['location'] ?? '',
        phones: List<String>.from(json['phones'] ?? []),
        visibleFacebook: json['visibleFacebook'] ?? true,
        visibleX: json['visibleX'] ?? true,
        visibleInstagram: json['visibleInstagram'] ?? true,
        visibleWebsite: json['visibleWebsite'] ?? true,
        visibleLinkedin: json['visibleLinkedin'] ?? true,
        visibleWhatsapp: json['visibleWhatsapp'] ?? true,
        visibleTiktok: json['visibleTiktok'] ?? true,
        visibleYoutube: json['visibleYoutube'] ?? true,
        visiblePhones: json['visiblePhones'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'facebook': facebook,
        'x': x,
        'instagram': instagram,
        'website': website,
        'linkedin': linkedin,
        'whatsapp': whatsapp,
        'tiktok': tiktok,
        'youtube': youtube,
        'location': location,
        'phones': phones,
        'visibleFacebook': visibleFacebook,
        'visibleX': visibleX,
        'visibleInstagram': visibleInstagram,
        'visibleWebsite': visibleWebsite,
        'visibleLinkedin': visibleLinkedin,
        'visibleWhatsapp': visibleWhatsapp,
        'visibleTiktok': visibleTiktok,
        'visibleYoutube': visibleYoutube,
        'visiblePhones': visiblePhones,
      };
  SocialLink copyWith({
    String? facebook,
    String? x,
    String? instagram,
    String? website,
    String? linkedin,
    String? youtube,
    String? whatsapp,
    String? tiktok,
    String? location,
    List<String>? phones,
    bool? visibleFacebook,
    bool? visibleX,
    bool? visibleInstagram,
    bool? visibleWebsite,
    bool? visibleLinkedin,
    bool? visibleYoutube,
    bool? visibleWhatsapp,
    bool? visibleTiktok,
    bool? visiblePhones,
  }) {
    return SocialLink(
      facebook: facebook ?? this.facebook,
      x: x ?? this.x,
      instagram: instagram ?? this.instagram,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
      youtube: youtube ?? this.youtube,
      whatsapp: whatsapp ?? this.whatsapp,
      tiktok: tiktok ?? this.tiktok,
      location: location ?? this.location,
      phones: phones ?? this.phones,
      visibleFacebook: visibleFacebook ?? this.visibleFacebook,
      visibleX: visibleX ?? this.visibleX,
      visibleInstagram: visibleInstagram ?? this.visibleInstagram,
      visibleWebsite: visibleWebsite ?? this.visibleWebsite,
      visibleLinkedin: visibleLinkedin ?? this.visibleLinkedin,
      visibleYoutube: visibleYoutube ?? this.visibleYoutube,
      visibleWhatsapp: visibleWhatsapp ?? this.visibleWhatsapp,
      visibleTiktok: visibleTiktok ?? this.visibleTiktok,
      visiblePhones: visiblePhones ?? this.visiblePhones,
    );
  }
}
