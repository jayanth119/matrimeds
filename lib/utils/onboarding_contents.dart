class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Identify Your Medicines Instantly",
    image: "assets/images/image1.png", 
    desc: "Simply snap a photo of your medicine to get complete details on usage, dosage, and precautions.",
  ),
  OnboardingContents(
    title: "Understand Diseases, Get Informed",
    image: "assets/images/image2.png",
    desc: "Search for any disease and access comprehensive, easy-to-understand information about symptoms, causes, and treatments.",
  ),
  OnboardingContents(
    title: "Your Personal Health AI Assistant",
    image: "assets/images/image3.png", 
    desc: "Chat one-on-one with our AI assistant for personalized advice and answers to your health queries.",
  ),
];