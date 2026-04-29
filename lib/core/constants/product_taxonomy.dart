// lib/core/constants/product_taxonomy.dart

class ProductTaxonomy {
  ProductTaxonomy._();

  static const List<String> categories = [
    'Digital Products',
    'IT Solutions',
    'AI Gadgets',
    'Fitness Tech',
    'Natural Essences',
    'Fashion',
    'Vehicles',
    'Real Estate',
  ];

  static const Map<String, List<String>> subcategoriesByCategory = {
    'Digital Products': [
      'Cameras',
      'Mobiles',
      'Chargers',
      'Power Banks',
      'Laptops',
      'Desktop Computers',
      'Monitors',
      'Keyboards',
      'Mice',
      'Printers',
      'Networking Devices',
      'Storage Devices',
      'Computer Accessories',
      'Mobile Accessories',
      'Audio Devices',
      'Gaming Accessories',
    ],

    'IT Solutions': [
      'Websites',
      'Mobile Apps',
      'AI Software',
      'SaaS Products',
      'E-commerce Systems',
      'Business Automation',
      'Chatbots',
      'CRM Systems',
      'ERP Systems',
      'POS Systems',
      'UI/UX Design',
      'Backend Development',
      'API Development',
      'Cloud Solutions',
      'Hosting Services',
      'Cybersecurity',
      'Maintenance Services',
      'IT Consultation',
    ],

    'AI Gadgets': [
      'Smart Watches',
      'Smart Glasses',
      'Smart Speakers',
      'AI Cameras',
      'Robotics',
      'Smart Home Devices',
      'Wearables',
      'Drones',
      'Security Devices',
    ],

    'Fitness Tech': [
      'Fitness Trackers',
      'Gym Equipment',
      'Smart Scales',
      'Massage Devices',
      'Yoga Accessories',
      'Sports Watches',
      'Recovery Devices',
    ],

    'Natural Essences': [
      'Essential Oils',
      'Perfume Oils',
      'Diffusers',
      'Aromatherapy',
      'Natural Extracts',
      'Spa Products',
      'Agarwood Products',
      'Agarwood Oil',
      'Oud Perfume',
      'Incense',
      'Bakhoor',
      'Luxury Gifts',
    ],

    'Fashion': [
      'Men Clothing',
      'Women Clothing',
      'Shoes',
      'Bags',
      'Watches',
      'Jewelry',
      'Accessories',
    ],

    'Vehicles': [
      'Cars',
      'Motorbikes',
      'Bicycles',
      'Vehicle Parts',
      'Vehicle Accessories',
      'Services',
    ],

    'Real Estate': [
      'Houses',
      'Apartments',
      'Land',
      'Commercial Property',
      'Rentals',
      'Property Services',
    ],
  };

  static List<String> subcategoriesFor(String category) {
    return subcategoriesByCategory[category] ?? const ['General'];
  }

  static String firstSubcategoryFor(String category) {
    final items = subcategoriesFor(category);
    return items.isEmpty ? 'General' : items.first;
  }

  static bool isValidCategory(String category) {
    return categories.contains(category);
  }

  static bool isValidSubcategory(String category, String subcategory) {
    return subcategoriesFor(category).contains(subcategory);
  }
}