class ChatMessage {
  final String id;
  final String userId;

  final String question;
  final String reponse;

  final String? maladieDetectee;

  const ChatMessage({
    required this.id,
    required this.userId,
    required this.question,
    required this.reponse,
    this.maladieDetectee,
  });
}