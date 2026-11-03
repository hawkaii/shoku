import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/services/voice_command_parser.dart';

void main() {
  group('English verbs', () {
    test('next', () {
      expect(parseVoiceCommand('next'), isA<NextStep>());
      expect(parseVoiceCommand('next step'), isA<NextStep>());
      expect(parseVoiceCommand('continue'), isA<NextStep>());
    });

    test('back', () {
      expect(parseVoiceCommand('back'), isA<PreviousStep>());
      expect(parseVoiceCommand('go back'), isA<PreviousStep>());
      expect(parseVoiceCommand('previous step'), isA<PreviousStep>());
    });

    test('repeat', () {
      expect(parseVoiceCommand('repeat'), isA<RepeatStep>());
      expect(parseVoiceCommand('say again'), isA<RepeatStep>());
    });

    test('timer with digits and words', () {
      expect((parseVoiceCommand('start a 5 minute timer') as StartTimer).minutes, 5);
      expect((parseVoiceCommand('timer 12 minutes') as StartTimer).minutes, 12);
      expect((parseVoiceCommand('set a timer for two minutes') as StartTimer).minutes, 2);
      expect((parseVoiceCommand('5 minute timer') as StartTimer).minutes, 5);
    });

    test('stop and help', () {
      expect(parseVoiceCommand('stop hands-free'), isA<StopHandsFree>());
      expect(parseVoiceCommand('stop listening'), isA<StopHandsFree>());
      expect(parseVoiceCommand('help'), isA<HelpCommand>());
      expect(parseVoiceCommand('what can I say'), isA<HelpCommand>());
    });

    test('anything else is a question', () {
      final command = parseVoiceCommand('is this spicy?') as AskQuestion;
      expect(command.text, 'is this spicy?');
    });

    test('empty speech is ignored', () {
      expect(parseVoiceCommand('   '), isA<IgnoredSpeech>());
    });
  });

  group('Hindi and Marathi verbs', () {
    test('Hindi', () {
      expect(parseVoiceCommand('अगला'), isA<NextStep>());
      expect(parseVoiceCommand('पीछे'), isA<PreviousStep>());
      expect(parseVoiceCommand('दोहराओ'), isA<RepeatStep>());
      expect((parseVoiceCommand('5 मिनट का टाइमर') as StartTimer).minutes, 5);
      expect(parseVoiceCommand('बंद करो'), isA<StopHandsFree>());
      expect(parseVoiceCommand('मदद'), isA<HelpCommand>());
    });

    test('Marathi', () {
      expect(parseVoiceCommand('पुढे'), isA<NextStep>());
      expect(parseVoiceCommand('मागे'), isA<PreviousStep>());
      expect(parseVoiceCommand('पुन्हा'), isA<RepeatStep>());
      expect((parseVoiceCommand('5 मिनिटांचा टायमर') as StartTimer).minutes, 5);
      expect(parseVoiceCommand('थांबा'), isA<StopHandsFree>());
      expect(parseVoiceCommand('मदत'), isA<HelpCommand>());
    });
  });
}
