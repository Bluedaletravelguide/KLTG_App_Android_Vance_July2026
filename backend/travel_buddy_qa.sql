CREATE TABLE IF NOT EXISTS travel_buddy_qa (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  patterns TEXT NOT NULL,
  answer TEXT NOT NULL,
  quick TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

TRUNCATE TABLE travel_buddy_qa;

INSERT INTO travel_buddy_qa (patterns, answer, quick) VALUES
('["hello","hi","hey","help","start"]', 'Hi there! 👋 Welcome to Malaysia! I\'m your friendly travel buddy here to help you explore.

Ask me anything about food, attractions, shopping, or planning your adventure!
Try: \'What should I do tonight?\' or \'Best food near me\'', '["First time tips","Best food spots","Top attractions"]'),
('["first time","first visit","new here","never been"]', 'Welcome to Malaysia! 🇲🇾 So excited you\'re here!

Must-do for first-timers:
• Try nasi lemak for breakfast
• Visit Petronas Twin Towers
• Explore Batu Caves
• Eat at Jalan Alor food street

The best months to visit are March-October for less rain. You\'ll love it here!', '["Airport tips","Hotel areas","Getting around"]'),
('["airport","klia","arrived","landing","sim card"]', 'Welcome to KLIA! 🛬 Here\'s what you need:

📱 SIM cards: Available at airport kiosks (Celcom, Digi, Maxis)
🚗 Transport: Grab works great, or take KLIA Express train (28min to KL)
💰 Money: ATMs and currency exchange available

The airport is modern and easy to navigate. Staff speak English! 😊

💡 Want to plan your trip in detail?
Check out KL The Guide! 👇', '["Best transport","Hotel distance","KL The Guide 🔗"]'),
('["weather","rain","hot","humid","temperature","when to visit","best time"]', 'Malaysia is warm year-round! 🌴

☀️ Temperature: 25-33°C (77-91°F)
💧 Humidity: High (bring light clothes!)
🌧️ Best months: March-October
🌊 Monsoon: November-February (East Coast)

Quick rain is common, but clears fast. Pack an umbrella!

💡 Need more travel tips?
Visit KL The Guide for detailed guides! 👇', '["What to wear","Indoor activities","KL The Guide 🔗"]'),
('["hotel","stay","accommodation","where to stay","homestay"]', 'Great hotel areas in KL:

🏙️ Bukit Bintang: Shopping & nightlife (10 min to KLCC)
🏢 KLCC: Upscale, near Twin Towers
🎨 Chinatown: Budget-friendly, cultural
🌿 Bangsar: Trendy cafes & residential

Most hotels offer airport pickup! Prices are very affordable 😊

💡 Need detailed area guides?
Check KL The Guide for neighborhood reviews! 👇', '["Bukit Bintang hotels","Budget options","KL The Guide 🔗"]'),
('["bukit bintang","bb","pavilion","tonight"]', 'Bukit Bintang is THE spot! 🌟 Here\'s your evening plan:

🍜 Jalan Alor (6-11pm): Legendary street food paradise
🛍️ Pavilion KL: Shopping + fountain show at 8pm
🍹 Changkat: Rooftop bars & nightlife
✨ TRX Exchange Park: Beautiful light displays

Everything is within walking distance! Safe to explore at night 🚶

💡 Want a complete Bukit Bintang guide?
Visit KL The Guide for more tips! 👇', '["Street food guide","Nightlife spots","KL The Guide 🔗"]'),
('["street food","jalan alor","hawker","cheap food"]', 'Street food is where the magic happens! 🔥

🌟 Jalan Alor: KL\'s most famous food street
  • Grilled wings, satay, char kuey teow
  • Go 6-7pm to beat crowds
  • Budget: RM10-25 per meal

Other spots:
• Chow Kit Market (local breakfast)
• Imbi Market (curry laksa)
• Madras Lane (Hokkien mee)

Don\'t worry - food stalls are clean and safe! 👍

💡 Looking for more hidden food spots?
Check KL The Guide\'s local favorites! 👇', '["Penang food","Night markets","KL The Guide 🔗"]'),
('["halal","muslim","pork free","islamic food"]', 'Malaysia is VERY halal-friendly! 🕌✨

Most restaurants are halal-certified. Look for the halal logo.
Non-halal places clearly display \'pork\' or \'non-halal\' signs.

Must-try halal spots:
• Nasi Kandar (Penang/KL)
• Banana Leaf Rice
• Roti Canai everywhere!

You\'ll have no problems finding amazing halal food anywhere 😊

💡 Need a complete halal dining guide?
Visit KL The Guide for certified restaurants! 👇', '["Halal restaurants","Malay cuisine","KL The Guide 🔗"]'),
('["vegetarian","vegan","no meat","veggie"]', 'Vegetarian food is easy to find! 🥗🌱

Look for:
• Chinese vegetarian restaurants (素食)
• Indian banana leaf rice (ask for veg)
• Roti canai with dhal
• Nasi lemak (skip the anchovies)

Tell servers: \'Tak mahu daging\' (no meat) or \'vegetarian\'

Areas: Brickfields (Little India) has tons of veggie options!

💡 Want a vegan/vegetarian restaurant list?
Browse KL The Guide for plant-based spots! 👇', '["Vegan cafes","Indian veg","KL The Guide 🔗"]'),
('["nasi lemak","national dish","coconut rice"]', 'Nasi Lemak is Malaysia\'s PRIDE! 🇲🇾🍚

What is it? Fragrant coconut rice with:
• Sambal (spicy sauce)
• Fried anchovies & peanuts
• Boiled egg
• Cucumber slices
+ Optional: fried chicken, rendang, squid

Where to try:
• Village Park Restaurant (famous!)
• Any mamak stall
• Hotel breakfast buffets

Price: RM5-15. Eaten for breakfast but good anytime!

💡 Discover the best nasi lemak spots!
Check KL The Guide\'s foodie recommendations! 👇', '["Other breakfast","Best nasi lemak","KL The Guide 🔗"]'),
('["drink","teh tarik","beverage","coffee","tea"]', 'Malaysian drinks are amazing! 🍹☕

Must-try:
☕ Teh Tarik: \'Pulled\' milk tea (sweet & frothy)
🥥 Coconut shake: Fresh & cold
🍋 Limau ais: Fresh lime juice
🧊 Cendol: Sweet icy dessert drink
☕ White coffee: Ipoh specialty

Find them at: Mamak stalls, kopitiam (coffee shops), food courts.
Try teh tarik - it\'s our national drink! 😊

💡 Want more drink recommendations?
Check KL The Guide for cafe reviews! 👇', '["Where to find","Dessert drinks","KL The Guide 🔗"]'),
('["penang food","penang","best food city","char kuey teow"]', 'Penang is FOOD PARADISE! 🏝️😍

Why Penang wins:
• Char Kuey Teow (best in Malaysia!)
• Assam Laksa (sour spicy noodles)
• Hokkien Mee (prawn noodles)
• Nasi Kandar (24/7 rice buffet)

Where to eat:
• Gurney Drive hawker center
• Chulia Street night market
• New Lane (Lorong Baru)

Foodies say: KL is great, but Penang is LEGENDARY! 🔥

💡 Planning a Penang food trip?
Visit KL The Guide for detailed reviews! 👇', '["Best hawker centers","Must-try dishes","KL The Guide 🔗"]'),
('["souvenir","gift","bring home","batik","what to buy"]', 'Best Malaysian souvenirs! 🎁🇲🇾

🎨 Batik: Hand-painted fabric (shirts, scarves)
🍫 Chocolates: Beryl\'s, Vochelle
🍪 Pineapple tarts & cookies
🧴 Local products: tongkat ali, bird\'s nest
🎭 Pewter: Royal Selangor crafts
☕ Coffee: White coffee from Ipoh

Where to shop:
• Central Market (craft & batik)
• KLIA airport (last minute!)
• Petaling Street (bargain!)

Tax refund available at airport for purchases >RM300!

💡 Want more souvenir shopping tips?
Browse KL The Guide for recommendations! 👇', '["Where to buy","Price guide","KL The Guide 🔗"]'),
('["electronics","gadget","phone","camera","tech"]', 'For electronics, head to:

💻 Plaza Low Yat: KL\'s tech hub!
  • 5 floors of gadgets
  • Competitive prices
  • Can bargain a bit

📱 Other spots:
• Digital Mall (near Low Yat)
• All-Asia (cameras)
• Airport duty-free

Tip: Compare prices! Warranty may differ from your country 📱

💡 Looking for tech shopping details?
Visit KL The Guide for store info! 👇', '["Shopping tips","Warranty info","KL The Guide 🔗"]'),
('["night market","pasar malam","jonker walk","street market"]', 'Night markets are SO fun! 🌙✨

🎪 Popular ones:
• Jonker Walk (Melaka) - Fri-Sun
• Chow Kit - Daily
• Bangsar Sunday Market
• Taman Connaught (Thu) - longest!

What to expect:
🍜 Street food galore
👕 Cheap clothes & accessories
🎮 Games & toys
🌻 Fresh fruits

Bargaining is expected! Start at 50% of asking price 😄

💡 Need a complete market guide?
Check KL The Guide for schedules! 👇', '["Market schedules","What to buy","KL The Guide 🔗"]'),
('["petronas","twin towers","klcc","towers"]', 'Petronas Twin Towers - Malaysia\'s ICON! 🏙️✨

📸 Best views:
• Skybridge (floor 41) + Observation Deck (86)
• Book online in advance!
• RM80-100 per person

⏰ Timings: 9am-9pm (closed Mon)

FREE alternatives:
• KLCC Park fountain show (8pm & 9pm)
• View from Traders Hotel Sky Bar
• Photos from Suria KLCC mall

Evening is magical with lights! 🌆

💡 Need more KLCC area tips?
Check KL The Guide for full details! 👇', '["Booking guide","Photo spots","KL The Guide 🔗"]'),
('["batu caves","temple","stairs","monkey","hindu"]', 'Batu Caves - INCREDIBLE! 🕉️🐒

What to expect:
• 272 rainbow stairs
• Giant golden statue
• Hindu temple inside cave
• Cheeky monkeys (hold your belongings!)

📍 30min from KL (take KTM Komuter)
💰 FREE entry
⏰ 6am-9pm

Dress code: Cover shoulders & knees
Go early morning to beat heat & crowds! 🌅

💡 Planning your Batu Caves visit?
Visit KL The Guide for transport tips! 👇', '["Getting there","Best time","KL The Guide 🔗"]'),
('["heritage","history","museum","culture","merdeka"]', 'Explore Malaysia\'s rich history! 🏛️📚

🏛️ KL Heritage Walk:
• Merdeka Square (Independence)
• Sultan Abdul Samad Building
• Masjid Jamek (mosque)
• Central Market (handicrafts)
• River of Life

🏙️ UNESCO Sites:
• George Town (Penang) - street art!
• Melaka - colonial history

Museums:
• Islamic Arts Museum (stunning!)
• National Museum

Most are walkable! Easy half-day tour 🚶

💡 Want a heritage walking route?
Browse KL The Guide for itineraries! 👇', '["Walking routes","Museum list","KL The Guide 🔗"]'),
('["melaka","malacca","historic city","a famosa"]', 'Melaka (Malacca) - UNESCO Heritage City! 🏰

Must-see:
🏛️ A Famosa Fort (1511!)
⛪ St. Paul\'s Church (ruins on hill)
🎨 Jonker Walk (night market Fri-Sun)
🚤 Melaka River cruise (RM25)
🕌 Red Dutch Square

📍 2 hours from KL by bus
💰 RM10-15 one-way
⏰ Perfect as day trip or overnight

Don\'t miss: Chicken rice balls & Nyonya food! 🍚✨

💡 Planning a Melaka day trip?
Check KL The Guide for complete itinerary! 👇', '["Day trip plan","Food spots","KL The Guide 🔗"]'),
('["penang island","george town","street art","penang hill"]', 'Penang - The Pearl of Orient! 🏝️🎨

Why visit:
🎨 Famous street art murals
🍜 BEST food in Malaysia!
🏛️ UNESCO heritage George Town
🏖️ Beaches (Batu Ferringhi)
🚡 Penang Hill cable car
🕉️ Kek Lok Si Temple (largest Buddhist temple)

📍 1-hour flight or 4-hour bus from KL
⏰ Need 2-3 days minimum

Rent a scooter to explore! 🛵

💡 Need a complete Penang guide?
Visit KL The Guide for everything! 👇', '["3-day itinerary","Best areas","KL The Guide 🔗"]'),
('["nature","outdoor","hiking","trek","jungle","mountain"]', 'Malaysia\'s nature is STUNNING! 🌿🏔️

🏔️ Mountains & Hills:
• Mount Kinabalu (highest in SEA!)
• Broga Hill (sunrise hike, 2hr)
• Penang Hill (cable car up!)

🌲 Rainforests:
• Taman Negara (oldest jungle!)
• Cameron Highlands (tea plantations)
• Endau Rompin

🏝️ Islands:
• Langkawi, Perhentian, Tioman
• Sipadan (world-class diving!)

Adventure level? I can suggest! 😊

💡 Need outdoor adventure guides?
Visit KL The Guide for hiking tips! 👇', '["Beginner trails","Adventure tours","KL The Guide 🔗"]'),
('["langkawi","island paradise","cable car","sky bridge"]', 'Langkawi - Island Paradise! 🏝️☀️

Must-do:
🚡 Cable Car + Sky Bridge (amazing views!)
🏖️ Pantai Cenang (main beach)
🦅 Eagle Square & boat tour
🌅 Sunset cruise
💦 Seven Wells Waterfall

📍 1-hour flight from KL
💰 Duty-free shopping (cheap chocolate!)
⏰ Need 3-4 days to enjoy

Rent a car - island is big! 🚗
Weather: Best Nov-March

💡 Planning a Langkawi trip?
Check KL The Guide for complete info! 👇', '["Island itinerary","Beach guide","KL The Guide 🔗"]'),
('["cameron highlands","tea","strawberry","highland","cool weather"]', 'Cameron Highlands - Cool Mountain Retreat! 🍓☕

Perfect for:
🍵 Tea plantation tours (BOH Tea)
🍓 Strawberry farms (pick your own!)
🌺 Flower gardens
🥦 Fresh veggie markets
🥾 Jungle trails (Mossy Forest)

📍 3-4 hours from KL by bus
🌡️ 15-25°C (bring jacket!)
⏰ Perfect 2-day trip

Stay in Tanah Rata (main town).
Try steamboat & scones with cream! 😊

💡 Need a Cameron Highlands guide?
Browse KL The Guide for tour details! 👇', '["2-day itinerary","What to pack","KL The Guide 🔗"]'),
('["train","lrt","mrt","monorail","rail","klia express"]', 'KL\'s trains are GREAT! 🚇💨

Types:
🚄 KLIA Express: Airport ↔️ City (28min, RM55)
🚇 LRT: Main city lines (Kelana Jaya, Ampang)
🚇 MRT: Newer, faster (SBK, Putrajaya)
🚝 Monorail: Through city center
🚂 KTM: Suburban (to Batu Caves!)

💳 Get MyRapid card (RM10 deposit)
💰 RM1-5 per trip
⏰ 6am-midnight

Very clean & safe! 😊

💡 Want a complete train guide?
Browse KL The Guide for route maps! 👇', '["Station map","Card guide","KL The Guide 🔗"]'),
('["plan","itinerary","schedule","how many days","trip plan"]', 'Let me help you plan! 📅✨

Perfect KL itinerary:

Day 1: KLCC → Batu Caves → Bukit Bintang
Day 2: Heritage walk → Central Market → KL Tower
Day 3: Day trip (Melaka or Genting)

With more time:
• 5-7 days: Add Penang or Langkawi
• 10-14 days: Cover East Malaysia (Sabah/Sarawak)

How long are you staying? I\'ll customize! 😊

💡 Need detailed day-by-day plans?
Check KL The Guide for full itineraries! 👇', '["3-day detailed","7-day plan","KL The Guide 🔗"]'),
('["safe","safety","dangerous","secure","theft","crime"]', 'Malaysia is SAFE for tourists! ✅😊

Safety tips:
👍 Generally very safe
👍 Locals are friendly & helpful
👍 Low violent crime

⚠️ Watch out for:
• Pickpockets in crowded areas
• Bag snatchers (rare, but hold bags tight)
• Scam taxis (use Grab!)

✅ Safe to:
• Walk at night in busy areas
• Use public transport
• Eat street food

You\'ll feel very comfortable here! 🇲🇾

💡 Need complete safety guide?
Check KL The Guide for travel tips! 👇', '["Safety tips","Emergency info","KL The Guide 🔗"]'),
('["wifi","internet","data","mobile","online","sim"]', 'Staying connected is EASY! 📱💨

Best SIM cards (at airport):
📶 Celcom, Digi, Maxis, U Mobile
💰 RM35-50 for tourist packs
📊 Unlimited data + calls (7-30 days)

WiFi:
• Most hotels: Fast & free
• Malls & cafes: Free WiFi
• Grab/food apps: Work everywhere

Coverage is excellent in cities!
Get SIM at airport - easiest! 😊

💡 Need SIM card comparison?
Browse KL The Guide for details! 👇', '["Best SIM card","WiFi spots","KL The Guide 🔗"]'),
('["language","english","speak","communicate","malay"]', 'Language in Malaysia 🗣️

Good news:
✅ English widely spoken in cities
✅ Hotels/restaurants all speak English
✅ Signs are bilingual

Useful Malay phrases:
• Hello: Selamat datang
• Thank you: Terima kasih
• Excuse me: Maaf
• How much: Berapa harga
• Delicious: Sedap!

Locals LOVE when you try Malay! 😊
You\'ll have zero problems communicating!

💡 Want more useful phrases?
Check KL The Guide for language tips! 👇', '["Common phrases","Translation help","KL The Guide 🔗"]'),
('["medical","hospital","health","doctor","treatment","check up"]', 'Malaysia = World-Class Healthcare! 🏥✨

Top hospitals:
🏥 Prince Court Medical Centre
🏥 Gleneagles KL
🏥 Sunway Medical Centre
🏥 Pantai Hospital

Why Malaysia:
💰 60-80% cheaper than US/UK
👨‍⚕️ Doctors trained internationally
🗣️ English-speaking staff
✈️ Easy appointment booking

Popular: Health screenings, dental, cosmetic surgery.
Insurance paperwork? Hospitals help! 😊

💡 Need hospital recommendations?
Check KL The Guide for medical info! 👇', '["Hospital list","Cost guide","KL The Guide 🔗"]'),
('["mosque","prayer","islam","muslim prayer","putra mosque"]', 'Beautiful mosques to visit! 🕌✨

Must-see:
🕌 Putra Mosque (Putrajaya) - Pink & stunning!
🕌 Masjid Negara (National Mosque)
🕌 Federal Territory Mosque
🕌 Crystal Mosque (Terengganu)

Visiting rules:
👗 Dress modestly (robes provided)
👟 Remove shoes
📸 Photos okay (be respectful)
🚫 Not during prayer times

⏰ Best time: 9am-5pm
💰 FREE entry

Non-Muslims welcome! Very peaceful 😊

💡 Planning a mosque tour?
Visit KL The Guide for visiting tips! 👇', '["How to visit","Prayer times","KL The Guide 🔗"]'),
('["temple","chinese temple","buddhist","hindu temple"]', 'Amazing temples to explore! 🏯🕉️

Hindu Temples:
🕉️ Batu Caves (iconic!)
🕉️ Sri Mahamariamman (oldest in KL)

Buddhist/Chinese Temples:
🏯 Thean Hou Temple (6-tier, beautiful!)
🏯 Kek Lok Si (Penang - largest!)
🏯 Sin Sze Si Ya (oldest in KL)

Visiting tips:
👗 Dress modestly
👟 Shoes off inside
📸 Photos usually okay
🙏 Be respectful of worshippers

💰 FREE (donations welcome)
Experience Malaysia\'s diversity! 🌈

💡 Want a complete temple guide?
Browse KL The Guide for details! 👇', '["Temple locations","Etiquette guide","KL The Guide 🔗"]'),
('["nightlife","bar","club","party","night out"]', 'KL nightlife is VIBRANT! 🍹🌃

Top areas:
🍸 Changkat Bukit Bintang: Rooftop bars, pubs
🎉 TREC KL: Clubs & live music
🏙️ Skybar @ Traders Hotel: KLCC views!
🍺 Bangsar: Chill bars & cafes
🎶 Jalan P. Ramlee: Upscale clubs

Must-try:
• Heli Lounge Bar (rooftop helipad!)
• Marini\'s on 57 (fancy cocktails)
• Reggae Bar (live bands)

⏰ Opens 5pm, peaks 10pm-2am
💰 Drinks RM25-50

Very safe & fun! 🎉

💡 Looking for nightlife spots?
Check KL The Guide for bar reviews! 👇', '["Bar locations","Club events","KL The Guide 🔗"]'),
('["currency","exchange","ringgit","atm","cash"]', 'Money matters! 💰🏦

Currency: Malaysian Ringgit (MYR/RM)
💵 USD 1 = RM 4-5 (approx)

Best ways to pay:
💳 Credit card widely accepted
🏧 ATMs everywhere (RM1-5 fee)
💵 Cash for street food/markets

Where to exchange:
✅ KL Sentral, Mid Valley (good rates)
❌ Avoid airport (poor rates)
❌ Hotels (worst rates)

Tip: Withdraw from ATM = best rate!
Most places accept card 😊

💡 Need money exchange tips?
Visit KL The Guide for details! 👇', '["Exchange spots","ATM guide","KL The Guide 🔗"]'),
('["tip","tipping","service charge","gratuity"]', 'Tipping in Malaysia 💵

Short answer: NOT required! 😊

Details:
🍽️ Restaurants: 10% service charge already added
🚗 Grab/taxi: Not expected (round up if you want)
🏨 Hotels: RM5-10 for porter/housekeeping (optional)
💇 Spa/salon: 10% if excellent service

Locals don\'t usually tip.
If you do, it\'s a nice surprise! 😊

Service staff are paid properly here!

💡 Want complete etiquette guide?
Check KL The Guide for tips! 👇', '["Tipping guide","Local customs","KL The Guide 🔗"]'),
('["visa","entry","passport","immigration","requirement"]', 'Visa requirements 🛂✈️

Good news: Most nationalities get
visa-FREE entry! 🎉

Common durations:
🇺🇸🇬🇧🇦🇺🇪🇺: 90 days
🇨🇳🇮🇳: 30 days (some need eVisa)
🇸🇬: 30 days

Requirements:
✅ Passport valid 6+ months
✅ Return/onward ticket
✅ Sufficient funds proof

Check: Malaysian Immigration website
for your country\'s specific rules 📱

💡 Need visa extension info?
Browse KL The Guide for guidance! 👇', '["Visa info","Requirements","KL The Guide 🔗"]'),
('["emergency","police","ambulance","help urgent"]', 'Emergency numbers in Malaysia! 🚨

📞 SAVE THESE:
• Police: 999
• Ambulance/Fire: 994
• Tourist Police: 03-2149 6590

Embassies:
Check your country\'s embassy number
when you arrive!

Lost/Stolen:
• Cards: Call bank immediately
• Passport: Contact embassy first
• Phone: Track via Find My Phone

Hospitals with 24/7 ER:
• Gleneagles, Pantai, Prince Court

Stay safe! Help is quick here 💙

💡 Need complete emergency guide?
Visit KL The Guide for all info! 👇', '["Emergency list","Hospital ER","KL The Guide 🔗"]'),
('["day trip","nearby","excursion","one day","genting"]', 'Awesome day trips from KL! 🚗💨

🎢 Genting Highlands (1hr)
  • Theme parks, casino, cool weather

🏛️ Melaka (2hrs)
  • UNESCO heritage, great food

🦅 Batu Caves (30min)
  • Hindu temple, monkeys, stairs!

🦀 Kuala Selangor (1.5hrs)
  • Fireflies boat tour at night

🍓 Cameron Highlands (3hrs)
  • Tea plantations (overnight better)

🏖️ Port Dickson (1.5hrs)
  • Beach escape

Easy to do yourself or book tours! 😊

💡 Want detailed day trip guides?
Visit KL The Guide for itineraries! 👇', '["Day trip plans","Tour booking","KL The Guide 🔗"]'),
('["spa","massage","relax","wellness","traditional massage"]', 'Relax & rejuvenate! 💆‍♀️✨

Traditional treatments:
🌿 Malay massage (full body)
🌺 Javanese lulur (body scrub)
🥥 Urut batin (traditional healing)

Where to go:
💎 Luxury: Mandara Spa, Spa Village
💰 Mid-range: Thai Odyssey, Bali Hai
💵 Budget: Local reflexology (RM50-80)

📍 Find them in malls & hotels
💰 RM100-400 for 1-2hrs
⏰ Book ahead for weekends

So affordable compared to home! 😊

💡 Looking for spa recommendations?
Check KL The Guide for reviews! 👇', '["Spa locations","Price ranges","KL The Guide 🔗"]'),
('["rain","raining","wet","indoor","rainy day"]', 'Rainy day? No problem! ☔😊

Indoor fun:
🛍️ Mall hopping (all connected!)
🐠 Aquaria KLCC (underwater tunnel)
🔬 Petrosains Science Centre
🖼️ Museum of Illusions
🎭 Islamic Arts Museum
🍜 Food court marathon!
☕ Cozy cafe hopping
💆 Spa day

Pro tip:
Malls in KL are HUGE - you can spend
all day exploring, eating, & shopping
in air-con comfort! 🌈

💡 Need rainy day itinerary?
Browse KL The Guide for ideas! 👇', '["Indoor spots","Mall guide","KL The Guide 🔗"]'),
('["photo","instagram","pictures","photogenic","beautiful photos"]', 'Instagram-worthy spots in KL! 📸✨

🌟 Best Photo Locations:
🌉 Saloma Bridge (evening lights!)
  Best time: 7-9pm for colors

⛲ KLCC Park (fountain + towers)
  📍 Grab the iconic reflection shot!

🌺 Perdana Botanical Gardens
  🌳 Lush greenery & flowers

🏮 Petaling Street (Chinatown)
  Red lanterns everywhere!

Other spots:
• Batu Caves rainbow stairs
• Putra Mosque (pink beauty!)
• Thean Hou Temple sunset

Golden hour = Magic! 🌅

💡 Want more Instagrammable spots?
Check KL The Guide for photo locations! 👇', '["Hidden photo spots","Photography tips","KL The Guide 🔗"]'),
('["festival","event","celebration","holiday","chinese new year"]', 'Malaysia\'s festivals are COLORFUL! 🎉🌈

Major celebrations:
🧧 Chinese New Year (Jan/Feb)
  • Red lanterns everywhere!
🕌 Hari Raya (Islamic)
  • After Ramadan fasting
🪔 Deepavali (Oct/Nov)
  • Festival of lights
🎄 Christmas (Dec)
  • Big decorations in malls

Special events:
• Malaysia Day (Sept 16)
• Merdeka Day (Aug 31)
• Thaipusam (Jan/Feb) - Batu Caves!

During festivals: expect crowds,
but AMAZING atmosphere! 🎊

💡 Planning around festivals?
Check KL The Guide for event calendar! 👇', '["Festival calendar","Event dates","KL The Guide 🔗"]'),
('["delivery","food delivery","order food","grabfood","app"]', 'Food delivery is EVERYWHERE! 📱🍜

Top apps:
🚗 GrabFood (most popular!)
🛵 Foodpanda
🍔 ShopeeFood (cheap deals!)

Why so good:
✅ Super fast (20-40min)
✅ Cheap delivery (RM2-5)
✅ Promos daily!
✅ Track your order

💰 Payment: Card or cash
🕐 Available: 7am-2am (some 24hr!)

Perfect for lazy hotel nights! 😊
Download: Grab, Foodpanda, Shopee

💡 Want restaurant recommendations?
Browse KL The Guide for delivery spots! 👇', '["App setup","Best promos","KL The Guide 🔗"]'),
('["family","kids","children","family friendly","with kids"]', 'Family-friendly fun in Malaysia! 👨‍👩‍👧‍👦💕

🎢 Top Attractions:
• Sunway Lagoon (water park + theme park!)
  💰 RM180-220 | Full day fun!

• Aquaria KLCC (underwater tunnel 🐠)
• Zoo Negara (Giant Panda!)
• KL Bird Park (world\'s largest!)

🎪 More ideas:
• Petrosains Science Center
• Kidzania (role-play city)
• Farm In The City
• Legoland (Johor)

Kids will LOVE Malaysia! 🌟

💡 Want a family itinerary?
Visit KL The Guide for kid-friendly plans! 👇', '["Age groups","Indoor options","KL The Guide 🔗"]'),
('["island","beach","islands","beach destination","seaside"]', 'Top island destinations! 🏝️☀️

🌊 Must-Visit Islands:
🦅 Langkawi (duty-free paradise!)
  • Cable car, beaches, sunsets
  • ✈️ 1hr flight from KL

🐠 Perhentian Islands (crystal clear!)
  • Snorkeling, diving heaven
  • Budget-friendly

🌴 Tioman Island (jungle + beach)
  • Pristine nature

🤿 Sipadan (world\'s best diving!)
  • Sabah - bucket list!

🦀 Pangkor Island (laid-back vibes)
  • Easy from KL (3hrs)

Best season: March-October! 🌞

💡 Planning an island trip?
Visit KL The Guide for island guides! 👇', '["Island comparison","Best beaches","KL The Guide 🔗"]'),
('["hidden gem","underrated","secret spot","off beaten","lesser known"]', 'Hidden gems - locals\' favorites! 💎🤫

🌟 5 Underrated Spots:
🌾 Sekinchan Rice Fields
  • Golden paddy views!
  • 📍 2hrs from KL
  • Fresh seafood too!

✨ Kuala Selangor Fireflies
  • Magical boat tour at night
  • Nature\'s light show! 🌙

🪞 Sasaran Sky Mirror
  • Bolivia-style reflection!
  • Seasonal (check timing)

🏔️ Kundasang (Sabah)
  • "New Zealand of Malaysia"
  • Dairy farms, cool air

🏝️ Kapas Island
  • Quiet, pristine beaches
  • Less touristy!

Escape the crowds! 🌿

💡 Want more secret spots?
Check KL The Guide for local favorites! 👇', '["More hidden gems","Local tips","KL The Guide 🔗"]'),
('["sunset","sunset view","golden hour","evening view"]', 'Best sunset spots in Malaysia! 🌅✨

🌇 Top Sunset Views:
🌉 Langkawi SkyBridge
  • 360° island & sea views
  • Absolutely stunning!

🏯 Kek Lok Si Temple Hill (Penang)
  • Temple + sunset combo
  • Magical atmosphere

🏖️ Tanjung Aru Beach (Sabah)
  • Famous sunset beach
  • Food stalls nearby

Other great spots:
• KLCC Park (city sunset)
• Putra Mosque lakeside
• Port Dickson beaches

⏰ Best time: 6:30-7:30pm
Bring your camera! 📸

💡 Looking for more sunset spots?
Visit KL The Guide for recommendations! 👇', '["Sunset timing","Nearby cafes","KL The Guide 🔗"]'),
('["rainforest","jungle","trekking","nature park","wildlife"]', 'Experience Malaysia\'s ancient rainforest! 🌳🦜

🌿 Top Rainforest Destinations:
🏞️ Taman Negara
  • 130 million years old!
  • Canopy walk, river cruise
  • Wildlife spotting
  • 📍 3-4hrs from KL

🏔️ Kinabalu Park (Sabah)
  • UNESCO World Heritage
  • Mount Kinabalu (4,095m!)
  • Unique flora & fauna
  • ✈️ Fly to Kota Kinabalu

What to expect:
• Guided jungle treks
• Night safaris
• River activities
• Authentic nature experience!

Hire local guides recommended! 🥾

💡 Want jungle adventure tips?
Browse KL The Guide for trekking info! 👇', '["Packing list","Tour operators","KL The Guide 🔗"]'),
('["city view","best view","skyline","panorama","observation"]', 'Best city views in KL! 🌆🔝

🏙️ Top Viewing Spots:
• KL Tower Sky Deck (421m high!)
  💰 RM52 | ⏰ 9am-10pm

• Banyan Tree Rooftop Bar
  🍹 Drinks with a view!

• Petronas Sky Bridge (floor 86)
  💰 RM80-100 | Book ahead!

• KLCC Park (free ground view!)
• Traders Hotel Sky Bar

Evening/night is MAGICAL with lights! ✨

💡 Looking for more viewing spots?
Check KL The Guide for recommendations! 👇', '["Rooftop bars","Best timing","KL The Guide 🔗"]'),
('["thanks","thank you","appreciate","helpful"]', 'You\'re so welcome! 🌟😊

Have an AMAZING time in Malaysia!
The food, the people, the sights -
you\'re going to love it here! 🇲🇾💕

Need anything else? Just ask!
I\'m here to help make your trip
unforgettable! ✨

Selamat datang ke Malaysia! 🎉
(Welcome to Malaysia!)

💡 Want even more travel tips?
Visit KL The Guide for everything! 👇', '["More questions","Plan my trip","KL The Guide 🔗"]'),
('["bye","goodbye","see you","done","finish"]', 'Safe travels, friend! 🌏✨

Enjoy every moment in Malaysia!
Eat lots, explore tons, and make
amazing memories! 📸🍜

Come back anytime you need help!

Selamat jalan! (Safe journey!) 🇲🇾💙

💡 Before you go, check out:
KL The Guide for complete travel info! 👇', '["One more question","KL The Guide 🔗"]'),
('["recommend","suggestion","what should","advice"]', 'I\'d love to help! 😊

Tell me more about what you like:
🍜 Foodie? → Best restaurants & street food
🏛️ History buff? → Heritage sites & museums
🏖️ Beach lover? → Island hopping
🛍️ Shopaholic? → Malls & markets
🌿 Nature person? → Hiking & parks
👨‍👩‍👧‍👦 Family trip? → Kid-friendly spots

Or ask specific things like:
\'Best dinner spot near KLCC?\'
\'Easy hike with great views?\'

💡 Need personalized recommendations?
Browse KL The Guide for curated lists! 👇', '["Food spots","Attractions","KL The Guide 🔗"]'),
('["where","how","what","when","can you","tell me","show me"]', 'I\'d be happy to help! 🌟

I know about:
• Food & restaurants 🍜
• Attractions & sights 🏛️
• Shopping & markets 🛍️
• Transportation tips 🚇
• Hotels & areas 🏨
• Day trips & tours 🚗
• Practical travel info 📱

Try asking something specific like:
\'Top 5 attractions in KL?\'
\'Best breakfast near Bukit Bintang?\'
\'How to get to Batu Caves?\'

💡 Want comprehensive guides?
Check KL The Guide for everything! 👇', '["Popular questions","Travel tips","KL The Guide 🔗"]');
