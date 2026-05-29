class SkillModel {
  final String id;
  final String slug;
  final String name;
  final String description;
  final String icon;
  final String color;
  final String category;
  final int totalLessons;
  final int orderIndex;
  final bool isActive;

  SkillModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    this.totalLessons = 0,
    this.orderIndex = 0,
    this.isActive = true,
  });

  factory SkillModel.fromMap(Map<String, dynamic> map) {
    return SkillModel(
      id:           map['id'] as String,
      slug:         map['slug'] as String,
      name:         map['name'] as String,
      description:  map['description'] as String? ?? '',
      icon:         map['icon'] as String? ?? '💻',
      color:        map['color'] as String? ?? '#6366F1',
      category:     map['category'] as String? ?? 'programming',
      totalLessons: map['total_lessons'] as int? ?? 0,
      orderIndex:   map['order_index'] as int? ?? 0,
      isActive:     map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':           id,
      'slug':         slug,
      'name':         name,
      'description':  description,
      'icon':         icon,
      'color':        color,
      'category':     category,
      'total_lessons':totalLessons,
      'order_index':  orderIndex,
      'is_active':    isActive,
    };
  }
}