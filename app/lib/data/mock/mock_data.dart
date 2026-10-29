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
  static const List<SavedItem> items = [
    SavedItem(
      id: 'mousse',
      title: 'Protein Rich Mousse',
      subtitle: 'A simple and protein-packed mousse from four ingredients.',
      kind: ItemKind.recipe,
      source: ItemSource.instagram,
      sourceHandle: '@highprotein.eats',
      duration: '0:48',
      minutesAgo: 31,
      tags: ['high protein', 'dessert', '4 ingredients'],
      pantryHave: 2,
      pantryNeed: 4,
      xp: 40,
      body: [
        'Separate four eggs. Whisk the yolks with cocoa and a pinch of salt until the mixture falls in a ribbon.',
        'Whip the whites to soft peaks, then fold them in twenty slow strokes. Stop while you can still see streaks — that is the lift.',
        'Chill for two hours minimum. Overnight is better; the cocoa reads darker and the texture sets firm.',
        'Finish with flaked salt before serving. It cuts the sweetness and makes the whole thing taste more expensive than it is.',
      ],
      progressDone: 0,
      progressTotal: 6,
    ),
    SavedItem(
      id: 'salt-onions',
      title: 'Salt Your Onions the Second They Hit the Pan',
      subtitle: 'The one habit that makes every sauce taste like it took longer.',
      kind: ItemKind.wisdom,
      source: ItemSource.instagram,
      sourceHandle: '@salt.fat.acid',
      duration: '0:37',
      minutesAgo: 64,
      tags: ['technique', 'sauce'],
      xp: 15,
      body: [
        'Salt draws water out, and water is the enemy of browning. Salt first, then leave them alone.',
        'Do not stir for the first three minutes. The pan is doing the work; your spoon is undoing it.',
        'When the edges go translucent and the bottom sticks a little, that fond is the whole flavour of the sauce.',
        'Deglaze with a splash of whatever you are drinking, not water. Water just washes the flavour away.',
      ],
    ),
    SavedItem(
      id: 'chicken',
      title: 'Crispy Chilli Chicken',
      subtitle: 'Takeaway-style crunch without a deep fryer.',
      kind: ItemKind.recipe,
      source: ItemSource.youtube,
      sourceHandle: 'Kitchen Sanctuary',
      duration: '8:20',
      minutesAgo: 120,
      tags: ['dinner', 'spicy', 'takeaway'],
      pantryHave: 6,
      pantryNeed: 8,
      xp: 60,
      body: [
        'Cube the thigh, salt it early, and let it sit fifteen minutes so the surface dries.',
        'Cornflour, not plain flour. The crust should be glassy, not bready.',
        'Sauce goes in last, off the heat, so the coating stays crisp for the first three minutes.',
        'Serve immediately. This is not a dish that waits, and it is not a dish that reheats.',
      ],
      progressDone: 2,
      progressTotal: 5,
    ),
    SavedItem(
      id: 'bread',
      title: 'No-Knead Focaccia, Overnight',
      subtitle: 'Eighteen hours of doing nothing, then twenty minutes of work.',
      kind: ItemKind.recipe,
      source: ItemSource.youtube,
      sourceHandle: 'Bread Code',
      duration: '11:04',
      minutesAgo: 300,
      tags: ['baking', 'bread', 'weekend'],
      pantryHave: 3,
      pantryNeed: 5,
      xp: 45,
      body: [
        'Mix everything with a spoon until no dry flour remains. It should look wrong and shaggy.',
        'Olive oil goes into the pan first, generously, then the dough on top of it.',
        'Dimple with oiled fingers right to the bottom of the pan. That is where the crisp edges come from.',
        'Bake hot. The difference between pale and golden is ten degrees and three minutes.',
      ],
    ),
    SavedItem(
      id: 'pantry-system',
      title: 'A Pantry That Tells You What to Cook',
      subtitle: 'Stop buying duplicates. Start cooking what you already own.',
      kind: ItemKind.wisdom,
      source: ItemSource.youtube,
      sourceHandle: 'Home Kitchen',
      duration: '6:30',
      minutesAgo: 1440,
      tags: ['systems', 'pantry'],
      xp: 20,
      body: [
        'Group by how fast a thing dies, not by cuisine. Fresh herbs next to fresh dairy, dry goods together.',
        'One shelf is for what must be eaten this week. Everything else is storage.',
        'Shop from the shelf, not the recipe. The recipe is a suggestion; the shelf is the constraint.',
      ],
    ),
  ];

  static const List<StashCollection> collections = [
    StashCollection('Weeknight dinners', '🍳', 12),
    StashCollection('Bread & dough', '🥖', 7),
    StashCollection('Sauce notes', '🥄', 5),
    StashCollection('Places to eat', '📍', 3),
  ];

  static const List<PantryItem> pantry = [
    PantryItem('Eggs', '6 left', '🥚'),
    PantryItem('Cocoa powder', '250 g', '🍫'),
    PantryItem('Olive oil', 'half bottle', '🫒'),
    PantryItem('Basmati rice', '1 kg', '🍚'),
    PantryItem('Greek yoghurt', '400 g', '🥛'),
    PantryItem('Chilli flakes', 'plenty', '🌶️'),
    PantryItem('Garlic', '1 bulb', '🧄'),
    PantryItem('Cornflour', '100 g', '🥣'),
  ];

  static List<ShoppingItem> shoppingSeed() => [
        ShoppingItem('Chicken thighs', '500 g', 'Protein'),
        ShoppingItem('Spring onions', '1 bunch', 'Produce'),
        ShoppingItem('Cornflour', '100 g', 'Dry goods'),
        ShoppingItem('Greek yoghurt', '400 g', 'Dairy', done: true),
        ShoppingItem('Cocoa powder', '250 g', 'Dry goods'),
      ];

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
