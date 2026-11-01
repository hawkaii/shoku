/// Mock-only data for the Shoku frontend. No backend, no network.
/// Swapping to real repositories later means replacing these providers,
/// not rewriting screens.
library;

enum ItemKind { recipe, wisdom }

enum ItemSource { instagram, youtube }

class SavedItem {
  final String id;
  final String title;
  final String subtitle;
  final ItemKind kind;
  final ItemSource source;
  final String sourceHandle;
  final String duration;
  final int minutesAgo;
  final List<String> tags;
  final List<String> body;
  final int pantryHave;
  final int pantryNeed;
  final int xp;
  final int? progressDone;
  final int? progressTotal;

  const SavedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.source,
    required this.sourceHandle,
    required this.duration,
    required this.minutesAgo,
    required this.tags,
    required this.body,
    this.pantryHave = 0,
    this.pantryNeed = 0,
    this.xp = 0,
    this.progressDone,
    this.progressTotal,
  });

  String get sourceLabel => source == ItemSource.instagram ? 'Instagram' : 'YouTube';
}

class PantryItem {
  final String name;
  final String quantity;
  final String emoji;

  const PantryItem(this.name, this.quantity, this.emoji);
}

class ShoppingItem {
  final String name;
  final String quantity;
  final String category;
  bool done;

  ShoppingItem(this.name, this.quantity, this.category, {this.done = false});
}

class StashCollection {
  final String name;
  final String emoji;
  final int count;

  const StashCollection(this.name, this.emoji, this.count);
}

class PlanTier {
  final String name;
  final String price;
  final String cadence;
  final List<String> perks;
  final bool highlighted;

  const PlanTier({
    required this.name,
    required this.price,
    required this.cadence,
    required this.perks,
    this.highlighted = false,
  });
}

class MockData {
  static const List<PlanTier> plans = [
    PlanTier(
      name: 'Free',
      price: '₹0',
      cadence: 'forever',
      perks: ['20 saves to start', '7 free saves each week', 'Unlimited pantry'],
    ),
    PlanTier(
      name: 'Starter pack',
      price: '₹199',
      cadence: 'one time',
      perks: ['50 extra saves', 'Saves never expire', 'Priority extraction'],
    ),
    PlanTier(
      name: 'Power pack',
      price: '₹499',
      cadence: 'one time',
      perks: ['200 extra saves', 'Saves never expire', 'Early features'],
      highlighted: true,
    ),
  ];

  static const List<Map<String, String>> helpTopics = [
    {
      'q': 'How do I save a reel?',
      'a': 'Share it from Instagram or YouTube and pick Shoku from the share sheet. It lands in Home in a few seconds.',
    },
    {
      'q': 'Why did my save fail?',
      'a': 'Private accounts and region-locked videos cannot be read. Share the original post rather than a repost.',
    },
    {
      'q': 'What counts as a save?',
      'a': 'One successful extraction. Retrying the same link does not use another save.',
    },
    {
      'q': 'Can I export a recipe?',
      'a': 'Yes. Open any saved item and use Share to send it out as plain text.',
    },
  ];

  const MockData._();
}
