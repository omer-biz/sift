export async function seed(db) {
  const notesCount = await db.notes.count();
  const tagsCount = await db.tags.count();

  if (notesCount > 0 || tagsCount > 0) {
    console.log("Database already seeded.");
    return;
  }

  const tagIds = await db.tags.bulkAdd([
    { name: "work", color: "indigo" },
    { name: "personal", color: "emerald" },
    { name: "ideas", color: "amber" },
    { name: "health", color: "red" },
    { name: "travel", color: "blue" },
    { name: "reading", color: "violet" },
    { name: "tech", color: "sky" },
    { name: "finance", color: "green" },
    { name: "todo", color: "pink" },
    { name: "random", color: "purple" },
  ]);

  const now = new Date();
  const withTimestamps = (daysAgo) => {
    const created = new Date(now.getTime() - daysAgo * 86400000);
    return {
      createdAt: created.toISOString(),
      updatedAt: created.toISOString(),
    };
  };

  await db.notes.bulkAdd([
    {
      title: "Weekly Standup Notes",
      content:
        "Discussed progress on the frontend refactor. Backend is behind schedule.",
      tagIds: [1],
      ...withTimestamps(7),
    },
    {
      title: "Meditation Tips",
      content: "Focus on breathing. Let thoughts pass by like clouds.",
      tagIds: [2, 4],
      ...withTimestamps(3),
    },
    {
      title: "Book List",
      content: "1. Deep Work\n2. Atomic Habits\n3. The Pragmatic Programmer",
      tagIds: [6],
      ...withTimestamps(5),
    },
    {
      title: "Startup Ideas",
      content:
        "What if there was an app that tracks your focus using webcam AI?",
      tagIds: [3, 8],
      ...withTimestamps(2),
    },
    {
      title: "Grocery List",
      content: "Milk, Bread, Eggs, Avocados, Coffee",
      tagIds: [2],
      ...withTimestamps(1),
    },
    {
      title: "Dream Vacation Plan",
      content: "Kyoto in April for cherry blossoms. Budget: $3,000.",
      tagIds: [2, 5],
      ...withTimestamps(0),
    },
    {
      title: "Fitness Log",
      content: "Ran 5km. Did 3 sets of pushups, sit-ups, and squats.",
      tagIds: [4],
      ...withTimestamps(10),
    },
    {
      title: "Reflections on 2024",
      content: "Lots of growth. Need to keep my balance better in 2025.",
      tagIds: [7],
      ...withTimestamps(20),
    },
    {
      title: "Crypto Watchlist",
      content: "BTC, ETH, SOL. Watching for good entry points.",
      tagIds: [9, 8],
      ...withTimestamps(4),
    },
    {
      title: "Random Thought",
      content: "Do penguins have knees? Gotta look that up.",
      tagIds: [10],
      ...withTimestamps(6),
    },
  ]);

  console.log("Database seeded");
}
