class Scripture {
  Scripture({
    this.passageid,
    this.content,
    this.reference,
  });

  String? passageid;
  String? content;
  String? reference;

static Scripture fromJson(Map<String, Object?> json) {
    return switch (json) {
      {
        'passage_id': final String passageid,
      } =>
        Scripture(
          passageid: passageid,
        ),
      {
        'content': final String content,
        'reference': final String reference,
      } =>
        Scripture(
          content: content,
          reference: reference
        ),
      _ => throw FormatException('Could not deserialize Scripture, json=$json'),
    };
  }

}


