import 'package:flutter/foundation.dart';

/// A sentence the cook said, reduced to one thing the app can do.
@immutable
sealed class VoiceCommand {
  const VoiceCommand();
}

class NextStep extends VoiceCommand {
  const NextStep();
}

class PreviousStep extends VoiceCommand {
  const PreviousStep();
}

class RepeatStep extends VoiceCommand {
  const RepeatStep();
}

class StopHandsFree extends VoiceCommand {
  const StopHandsFree();
}

class HelpCommand extends VoiceCommand {
  const HelpCommand();
}

class StartTimer extends VoiceCommand {
  const StartTimer(this.minutes);
  final int minutes;
}

class AskQuestion extends VoiceCommand {
  const AskQuestion(this.text);
  final String text;
}

class IgnoredSpeech extends VoiceCommand {
  const IgnoredSpeech();
}

/// Local grammar, no model call. English is always accepted; Hindi and Marathi
/// are first-class so a cook can keep their hands in the dough. Anything that is
/// not a verb becomes a question, which is the useful default.
VoiceCommand parseVoiceCommand(String transcript) {
  var text = transcript
      .toLowerCase()
      .replaceAll(RegExp(r'[।!?.,;:’“”"]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (text.isEmpty) return const IgnoredSpeech();

  // Verb phrases are matched before the timer so "stop the timer" can still be
  // a stop if the grammar ever grows that verb.
  if (_any(text, const [
    'stop hands free',
    'stop hands-free',
    'stop listening',
    'stop the hands free',
    'hands free off',
    'hands-free off',
    'बंद करो',
    'हैंड्स फ्री बंद',
    'रुको',
    'थांबा',
    'हात मोकळे बंद',
  ])) {
    return const StopHandsFree();
  }
  if (_any(text, const [
    'help',
    'what can i say',
    'commands',
    'मदद',
    'क्या कह सकता हूँ',
    'मदत',
    'काय म्हणू शकतो',
  ])) {
    return const HelpCommand();
  }
  if (_any(text, const [
    'repeat',
    'say again',
    'say that again',
    'again',
    'what was that',
    'दोहराओ',
    'दोहराएं',
    'फिर से',
    'पुन्हा',
    'पुन्हा सांगा',
  ])) {
    return const RepeatStep();
  }
  if (_any(text, const [
    'next',
    'next step',
    'continue',
    'forward',
    'अगला',
    'आगे',
    'पुढे',
    'पुढचा',
  ])) {
    return const NextStep();
  }
  if (_any(text, const [
    'back',
    'go back',
    'previous',
    'previous step',
    'पीछे',
    'पिछला',
    'मागे',
    'मागचा',
  ])) {
    return const PreviousStep();
  }

  final minutes = _timerMinutes(text);
  if (minutes != null) return StartTimer(minutes);

  return AskQuestion(transcript.trim());
}

bool _any(String text, List<String> phrases) =>
    phrases.any((phrase) => text == phrase || text.contains(phrase));

/// "start a 5 minute timer", "timer 5 minutes", "set a timer for 5 minutes",
/// "5 minute timer", "5 मिनट का टाइमर", "5 मिनिटांचा टाइमर".
int? _timerMinutes(String text) {
  if (!_any(text, const [
    'timer',
    'टाइमर',
    'टायमर',
  ])) {
    return null;
  }
  final match = RegExp(r'(\d{1,3})').firstMatch(text);
  final word = RegExp(r'\b(one|two|three|four|five|six|seven|eight|nine|ten)\b')
      .firstMatch(text);
  final value = match != null
      ? int.tryParse(match.group(1)!)
      : _numberWord(word?.group(1));
  if (value == null || value <= 0) return null;
  return value.clamp(1, 180);
}

int? _numberWord(String? word) => switch (word) {
      'one' => 1,
      'two' => 2,
      'three' => 3,
      'four' => 4,
      'five' => 5,
      'six' => 6,
      'seven' => 7,
      'eight' => 8,
      'nine' => 9,
      'ten' => 10,
      _ => null,
    };
