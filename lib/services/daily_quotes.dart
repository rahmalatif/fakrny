class DailyQuote {
  final String en;
  final String ar;
  final String category;

  const DailyQuote({
    required this.en,
    required this.ar,
    required this.category,
  });
}

const List<DailyQuote> dailyQuotes = [
  // Motivation
  DailyQuote(
    en: 'Small steps every day lead to big changes.',
    ar: 'الخطوات الصغيرة كل يوم بتوصلك لتغييرات كبيرة.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'Believe in yourself and keep going.',
    ar: 'ثق في نفسك وكمل طريقك.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'You are capable of more than you think.',
    ar: 'إنت تقدر تعمل أكتر مما تتخيل.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'Every accomplishment starts with the decision to try.',
    ar: 'كل إنجاز بيبدأ بقرار إنك تحاول.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'Your effort today is an investment in tomorrow.',
    ar: 'مجهودك النهارده استثمار في بكرة.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'The best time to start is now.',
    ar: 'أحسن وقت تبدأ فيه هو دلوقتي.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'Dream big, start small, act now.',
    ar: 'احلم كبير، ابدأ صغير، واتحرك دلوقتي.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'You are one step closer than you were yesterday.',
    ar: 'إنت النهارده أقرب لهدفك بخطوة عن امبارح.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'Keep going. Your future self will thank you.',
    ar: 'كمل، نفسك في المستقبل هتشكرَك.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'Every day is another chance to grow.',
    ar: 'كل يوم فرصة جديدة إنك تتطور.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'You do not have to be perfect to make progress.',
    ar: 'مش لازم تكون مثالي علشان تتقدم.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'Turn your plans into small daily actions.',
    ar: 'حوّل خططك لخطوات صغيرة تعملها كل يوم.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'Be proud of how far you have come.',
    ar: 'افتخر بكل الطريق اللي قطعته لحد دلوقتي.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'Great things take time. Keep showing up.',
    ar: 'الحاجات العظيمة بتاخد وقت، استمر في المحاولة.',
    category: 'motivation',
  ),
  DailyQuote(
    en: 'Your beginning does not define your ending.',
    ar: 'بدايتك مش هي اللي بتحدد نهايتك.',
    category: 'motivation',
  ),

  // Self-care and rest
  DailyQuote(
    en: 'Rest is productive, too.',
    ar: 'الراحة كمان جزء من الإنجاز.',
    category: 'selfCare',
  ),
  DailyQuote(
    en: 'You deserve a moment to breathe.',
    ar: 'إنت تستحق لحظة تهدى فيها وتاخد نفسك.',
    category: 'selfCare',
  ),
  DailyQuote(
    en: 'You do not have to do everything today.',
    ar: 'مش لازم تعمل كل حاجة النهارده.',
    category: 'selfCare',
  ),
  DailyQuote(
    en: 'Slow down. You are allowed to take your time.',
    ar: 'اهدَى، من حقك تاخد وقتك.',
    category: 'selfCare',
  ),
  DailyQuote(
    en: 'Taking care of yourself is never wasted time.',
    ar: 'اهتمامك بنفسك عمره ما بيكون وقت ضايع.',
    category: 'selfCare',
  ),
  DailyQuote(
    en: 'A quiet moment can make a big difference.',
    ar: 'لحظة هدوء ممكن تفرق كتير.',
    category: 'selfCare',
  ),
  DailyQuote(
    en: 'You can pause without giving up.',
    ar: 'تقدر تقف شوية ترتاح من غير ما تستسلم.',
    category: 'selfCare',
  ),
  DailyQuote(
    en: 'Give yourself permission to rest.',
    ar: 'اسمح لنفسك ترتاح من غير إحساس بالذنب.',
    category: 'selfCare',
  ),
  DailyQuote(
    en: 'Your worth is not measured by your productivity.',
    ar: 'قيمتك مش بتتقاس بقد إيه أنجزت.',
    category: 'selfCare',
  ),
  DailyQuote(
    en: 'Some days, doing your best means taking a break.',
    ar: 'في أيام، أفضل حاجة تعملها هي إنك ترتاح.',
    category: 'selfCare',
  ),
  DailyQuote(
    en: 'Protect your peace whenever you can.',
    ar: 'حافظ على سلامك النفسي على قد ما تقدر.',
    category: 'selfCare',
  ),
  DailyQuote(
    en: 'You are allowed to have an unproductive day.',
    ar: 'من حقك يكون عندك يوم مش مليان إنجازات.',
    category: 'selfCare',
  ),
  DailyQuote(
    en: 'Breathe. You do not need to figure everything out now.',
    ar: 'خد نفس، مش لازم تفهم وتحل كل حاجة دلوقتي.',
    category: 'selfCare',
  ),

  // Personal growth
  DailyQuote(
    en: 'Become a little better than yesterday.',
    ar: 'خليك أحسن شوية من نفسك بتاعة امبارح.',
    category: 'growth',
  ),
  DailyQuote(
    en: 'Growth begins when you try something new.',
    ar: 'التطور بيبدأ لما تجرب حاجة جديدة.',
    category: 'growth',
  ),
  DailyQuote(
    en: 'Learn from yesterday and grow through today.',
    ar: 'اتعلم من امبارح واتطور خلال النهارده.',
    category: 'growth',
  ),
  DailyQuote(
    en: 'Mistakes are part of learning.',
    ar: 'الأخطاء جزء طبيعي من التعلم.',
    category: 'growth',
  ),
  DailyQuote(
    en: 'Be patient with the person you are becoming.',
    ar: 'اصبر على نفسك وإنت بتتطور وبتتغير.',
    category: 'growth',
  ),
  DailyQuote(
    en: 'Challenge yourself, but be kind to yourself.',
    ar: 'اتحدى نفسك، بس خليك رحيم بيها.',
    category: 'growth',
  ),
  DailyQuote(
    en: 'Every new skill starts with being a beginner.',
    ar: 'كل مهارة جديدة بتبدأ بإنك تكون مبتدئ.',
    category: 'growth',
  ),
  DailyQuote(
    en: 'Change takes time. Give yourself room to grow.',
    ar: 'التغيير بياخد وقت، ادي لنفسك فرصة تتطور.',
    category: 'growth',
  ),
  DailyQuote(
    en: 'Your journey does not have to look like anyone else’s.',
    ar: 'رحلتك مش لازم تكون شبه رحلة أي حد تاني.',
    category: 'growth',
  ),
  DailyQuote(
    en: 'Be willing to learn, unlearn, and grow.',
    ar: 'خليك مستعد تتعلم، وتراجع أفكارك، وتتطور.',
    category: 'growth',
  ),
  DailyQuote(
    en: 'Progress starts with an honest first step.',
    ar: 'التقدم بيبدأ بخطوة أولى حقيقية.',
    category: 'growth',
  ),
  DailyQuote(
    en: 'Focus on becoming, not comparing.',
    ar: 'ركز على تطورك، مش على مقارنة نفسك بغيرك.',
    category: 'growth',
  ),
  DailyQuote(
    en: 'You can start again with more wisdom.',
    ar: 'تقدر تبدأ من جديد بخبرة وفهم أكتر.',
    category: 'growth',
  ),

  // Life
  DailyQuote(
    en: 'Not every day has to be perfect to be meaningful.',
    ar: 'مش لازم كل يوم يكون مثالي علشان يكون له معنى.',
    category: 'life',
  ),
  DailyQuote(
    en: 'Make room for the little things that make you happy.',
    ar: 'سيب مساحة للحاجات الصغيرة اللي بتفرحك.',
    category: 'life',
  ),
  DailyQuote(
    en: 'Life is happening in the moments you often overlook.',
    ar: 'الحياة موجودة في اللحظات الصغيرة اللي ساعات بنعديها.',
    category: 'life',
  ),
  DailyQuote(
    en: 'Enjoy the journey, not just the destination.',
    ar: 'استمتع بالرحلة، مش بالوصول بس.',
    category: 'life',
  ),
  DailyQuote(
    en: 'Some of the best things grow slowly.',
    ar: 'بعض أجمل الحاجات بتكبر وتتطور بهدوء.',
    category: 'life',
  ),
  DailyQuote(
    en: 'You can find joy in ordinary moments.',
    ar: 'تقدر تلاقي فرحة في اللحظات العادية.',
    category: 'life',
  ),
  DailyQuote(
    en: 'Life does not need to be rushed.',
    ar: 'الحياة مش سباق، ومش لازم تستعجلها.',
    category: 'life',
  ),
  DailyQuote(
    en: 'Leave room for unexpected good things.',
    ar: 'سيب مساحة للحاجات الحلوة اللي ممكن تحصل فجأة.',
    category: 'life',
  ),
  DailyQuote(
    en: 'A meaningful life is built one day at a time.',
    ar: 'الحياة اللي ليها معنى بتتبني يوم ورا يوم.',
    category: 'life',
  ),
  DailyQuote(
    en: 'Appreciate where you are while working toward where you want to be.',
    ar: 'قدّر مكانك الحالي وإنت بتسعى للمكان اللي نفسك توصله.',
    category: 'life',
  ),
  DailyQuote(
    en: 'There is beauty in beginning again.',
    ar: 'في جمال في إنك تبدأ من جديد.',
    category: 'life',
  ),
  DailyQuote(
    en: 'Let life surprise you sometimes.',
    ar: 'اسمح للحياة إنها تفاجئك بحاجات حلوة أوقات.',
    category: 'life',
  ),
  DailyQuote(
    en: 'Collect moments, not just accomplishments.',
    ar: 'اجمع لحظات حلوة، مش إنجازات وبس.',
    category: 'life',
  ),

  // Productivity
  DailyQuote(
    en: 'Focus on one thing at a time.',
    ar: 'ركز على حاجة واحدة في كل مرة.',
    category: 'productivity',
  ),
  DailyQuote(
    en: 'Done is better than perfect.',
    ar: 'إنك تخلص أحسن من إنك تستنى الكمال.',
    category: 'productivity',
  ),
  DailyQuote(
    en: 'Make time for what matters.',
    ar: 'خصص وقت للحاجات اللي فعلًا مهمة.',
    category: 'productivity',
  ),
  DailyQuote(
    en: 'Start small, but start today.',
    ar: 'ابدأ بحاجة صغيرة، بس ابدأ النهارده.',
    category: 'productivity',
  ),
  DailyQuote(
    en: 'A clear priority makes the next step easier.',
    ar: 'لما تحدد أولوياتك، الخطوة الجاية بتبقى أسهل.',
    category: 'productivity',
  ),
  DailyQuote(
    en: 'Consistency beats occasional perfection.',
    ar: 'الاستمرار أهم من إنك تعمل كل حاجة بمثالية أوقات.',
    category: 'productivity',
  ),
  DailyQuote(
    en: 'Your next small action matters.',
    ar: 'خطوتك الصغيرة الجاية ليها قيمة.',
    category: 'productivity',
  ),
  DailyQuote(
    en: 'Plan with purpose and leave room for life.',
    ar: 'خطط لهدفك، وسيب مساحة للحياة كمان.',
    category: 'productivity',
  ),
  DailyQuote(
    en: 'Progress is built through repeated effort.',
    ar: 'التقدم بيتبني بالمحاولة المستمرة.',
    category: 'productivity',
  ),
  DailyQuote(
    en: 'Do what you can with the time you have.',
    ar: 'اعمل اللي تقدر عليه بالوقت المتاح ليك.',
    category: 'productivity',
  ),
  DailyQuote(
    en: 'One completed task is a step forward.',
    ar: 'كل مهمة بتخلصها هي خطوة لقدام.',
    category: 'productivity',
  ),
  DailyQuote(
    en: 'Protect your focus from unnecessary distractions.',
    ar: 'حافظ على تركيزك وابعد عن المشتتات اللي ملهاش لازمة.',
    category: 'productivity',
  ),
  DailyQuote(
    en: 'You do not need to do it all; you need to begin.',
    ar: 'مش مطلوب منك تعمل كل حاجة، المطلوب إنك تبدأ.',
    category: 'productivity',
  ),

  // Self-love and self-worth
  DailyQuote(
    en: 'Give yourself the same kindness you give others.',
    ar: 'عامل نفسك بنفس اللطف اللي بتعامل بيه غيرك.',
    category: 'selfLove',
  ),
  DailyQuote(
    en: 'You are worthy even on your hardest days.',
    ar: 'إنت ليك قيمة حتى في أصعب أيامك.',
    category: 'selfLove',
  ),
  DailyQuote(
    en: 'Speak to yourself with kindness.',
    ar: 'كلم نفسك بلطف بدل ما تكون قاسي عليها.',
    category: 'selfLove',
  ),
  DailyQuote(
    en: 'You do not have to earn the right to rest.',
    ar: 'مش لازم تثبت إنك تستحق الراحة.',
    category: 'selfLove',
  ),
  DailyQuote(
    en: 'Celebrate yourself for trying.',
    ar: 'قدّر نفسك لمجرد إنك بتحاول.',
    category: 'selfLove',
  ),
  DailyQuote(
    en: 'Your value is not determined by others’ opinions.',
    ar: 'قيمتك مش بتتحدد بآراء الناس عنك.',
    category: 'selfLove',
  ),
  DailyQuote(
    en: 'It is okay to put yourself on your priority list.',
    ar: 'عادي تحط نفسك ضمن أولوياتك.',
    category: 'selfLove',
  ),
  DailyQuote(
    en: 'You are allowed to outgrow old expectations.',
    ar: 'من حقك تتغير وتتجاوز توقعات قديمة عن نفسك.',
    category: 'selfLove',
  ),
  DailyQuote(
    en: 'Treat your mistakes as moments to learn.',
    ar: 'اعتبر أخطاءك فرص تتعلم منها، مش أسباب تلوم نفسك.',
    category: 'selfLove',
  ),
  DailyQuote(
    en: 'You deserve patience from yourself, too.',
    ar: 'إنت كمان تستحق إنك تصبر على نفسك.',
    category: 'selfLove',
  ),
  DailyQuote(
    en: 'You can be a work in progress and still be proud.',
    ar: 'ممكن تكون لسه بتتطور وفي نفس الوقت تكون فخور بنفسك.',
    category: 'selfLove',
  ),
  DailyQuote(
    en: 'Your needs matter, too.',
    ar: 'احتياجاتك مهمة هي كمان.',
    category: 'selfLove',
  ),

  // Positivity and hope
  DailyQuote(
    en: 'There is always something worth looking forward to.',
    ar: 'دايمًا فيه حاجة حلوة تستاهل تستناها.',
    category: 'positivity',
  ),
  DailyQuote(
    en: 'A difficult day does not mean a difficult life.',
    ar: 'اليوم الصعب مش معناه إن حياتك كلها صعبة.',
    category: 'positivity',
  ),
  DailyQuote(
    en: 'Small moments of joy still count.',
    ar: 'لحظات الفرح الصغيرة ليها قيمة برضه.',
    category: 'positivity',
  ),
  DailyQuote(
    en: 'Tomorrow is another opportunity.',
    ar: 'بكرة فرصة جديدة.',
    category: 'positivity',
  ),
  DailyQuote(
    en: 'Look for what is going right, too.',
    ar: 'بص كمان للحاجات اللي ماشية كويس في حياتك.',
    category: 'positivity',
  ),
  DailyQuote(
    en: 'Hope can begin with one small possibility.',
    ar: 'الأمل ممكن يبدأ باحتمال صغير.',
    category: 'positivity',
  ),
  DailyQuote(
    en: 'You have made it through difficult days before.',
    ar: 'إنت عديت بأيام صعبة قبل كده وقدرت تكمل.',
    category: 'positivity',
  ),
  DailyQuote(
    en: 'Give today a chance to surprise you.',
    ar: 'ادي لنهارده فرصة يفاجئك بحاجة حلوة.',
    category: 'positivity',
  ),
  DailyQuote(
    en: 'A new perspective can open a new door.',
    ar: 'نظرة مختلفة ممكن تفتح باب جديد.',
    category: 'positivity',
  ),
  DailyQuote(
    en: 'Even a little light can change a room.',
    ar: 'حتى النور البسيط يقدر يغيّر المكان.',
    category: 'positivity',
  ),
  DailyQuote(
    en: 'There is no shame in starting over.',
    ar: 'مفيش أي عيب إنك تبدأ من جديد.',
    category: 'positivity',
  ),
  DailyQuote(
    en: 'Let yourself believe that good things are possible.',
    ar: 'اسمح لنفسك تصدق إن الحاجات الحلوة ممكن تحصل.',
    category: 'positivity',
  ),

  // Balance and mindfulness
  DailyQuote(
    en: 'Be present for the life you are living now.',
    ar: 'عيش اللحظة اللي إنت فيها بدل ما تفكر طول الوقت في اللي جاي.',
    category: 'mindfulness',
  ),
  DailyQuote(
    en: 'You can take life one moment at a time.',
    ar: 'تقدر تعيش الحياة لحظة بلحظة.',
    category: 'mindfulness',
  ),
  DailyQuote(
    en: 'Not everything needs an immediate answer.',
    ar: 'مش كل حاجة لازم يكون ليها رد أو حل فوري.',
    category: 'mindfulness',
  ),
  DailyQuote(
    en: 'Make space for silence and reflection.',
    ar: 'خصص وقت للهدوء ومراجعة نفسك.',
    category: 'mindfulness',
  ),
  DailyQuote(
    en: 'Notice how far you have come, not only how far you have to go.',
    ar: 'لاحظ إنت وصلت لفين، مش بس فاضلك قد إيه.',
    category: 'mindfulness',
  ),
  DailyQuote(
    en: 'Let go of what you cannot control.',
    ar: 'سيب اللي مش في إيدك تتحكم فيه.',
    category: 'mindfulness',
  ),
  DailyQuote(
    en: 'You can care deeply without carrying everything.',
    ar: 'ممكن تهتم من قلبك من غير ما تشيل كل حاجة لوحدك.',
    category: 'mindfulness',
  ),
  DailyQuote(
    en: 'Balance is built one choice at a time.',
    ar: 'التوازن بيتبني باختيارات صغيرة كل يوم.',
    category: 'mindfulness',
  ),
  DailyQuote(
    en: 'Listen to what you need, not only what is expected.',
    ar: 'اسمع احتياجاتك، مش بس توقعات الناس منك.',
    category: 'mindfulness',
  ),
  DailyQuote(
    en: 'You can be grateful and still want to grow.',
    ar: 'تقدر تكون ممتن للي عندك ولسه عندك رغبة تتطور.',
    category: 'mindfulness',
  ),
];
