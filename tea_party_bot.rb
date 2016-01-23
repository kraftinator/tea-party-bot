require 'active_support'
require_relative 'source_text'
## require '../project/bernie-bot/bernie_bot'

class TeaPartyBot

  MAX_CHARS = 140
  
  attr_accessor :texts
  
  def initialize( client )
    @texts = source_texts( client )
    #@texts = source_texts_new_test
  end
  
  def tweet_length(text)
    ActiveSupport::Multibyte::Chars.new(text).normalize(:c).length 
  end
  
  def valid_tweet?(text)
    return false if text.nil?
    tweet_length(text) <= MAX_CHARS ? true : false
  end
  
  def build_text
    first_text = @texts.shuffle.first
    second_texts = @texts.find_all { |t| t.category == first_text.category }
    second_texts.delete_if { |t| ( t.first_part == first_text.first_part ) or ( !valid_tweet?("#{first_text.first_part} #{t.second_part}") ) }
    return false, "NOT POSSIBLE: #{first_text.first_part}" if second_texts.empty?
    second_text = second_texts.shuffle.first
    result = "#{first_text.first_part} #{second_text.second_part}"
    
    ## Return false if too many colons
    return false, "TOO MANY COLONS: #{result}" if result.count(':') > 1
    
    ## Return false for certain word combos 
    return false, "INVALID WORD COMBO: #{result}" if result =~ /because for/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /because is/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /because was/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /can have to/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /from teens pleads/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /it should it/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /might it/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /one who aren't/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /shall of/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /should do that is/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /their will/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /we should it/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /when is to/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /when here/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /when also/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /when was/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /when would/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /which also to/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /while is/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /while of/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /will for/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /will it be/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /will of/i
    
    ################
    ## Edit result
    ################
    
    # Double quotation marks
    result.gsub!('“', '"')
    result.gsub!('”', '"')
    
    # Single quotaion marks
    result.gsub!(" '", " ")
    result.gsub!("' ", " ")
    
    result.gsub!(" ’", " ")
    result.gsub!("’ ", " ")

    result.gsub!(" ‘", " ")
    result.gsub!("‘ ", " ")

    result.gsub!("'.", ".")
    result.gsub!("’.", ".")
    result.gsub!("‘.", ".")
    
    ## Validate parentheses
    left_parentheses = result.count("(")
    right_parentheses = result.count(")")
    return false, "INVALID PARENTHESES: #{result}" if left_parentheses != right_parentheses
    
    quote_count = result.count('"')
    return false, "INVALID QUOTES: #{result}" if quote_count > 0 and quote_count.odd?
    
    ## Remove extra period
    result.gsub!("?.", "?")
    result.gsub!("!.", "!")
    result.gsub!(":.", ":")
    result.gsub!("..", ".")
    if result.split(//).last(2).join == ".." and result.split(//).last(3).join != "..."
      result = result.chomp(".")
    end

    if result[0] == '@'
      result = ".#{result}"
    end
    
    ## If result ends with colon, replace colon with period.
    if result.last == ':'
      result = result.chomp(":")
      result = "#{result}."
    end
    
    ## Unescape result
    result = CGI.unescapeHTML( result )
    
    if valid_tweet?(result)
      return true, result
    else
      return false, "TOO LONG"
    end
  end
  
  def source_texts_new_test
    @texts = []       
    corpus_list = ["Going out of town this weekend. I won't have internet access. Will be back on January 18..", "Blames current whites for the past. I have nothing to be ashamed of. No white guilt. Not responsible for the past..", "Maybe they just weren't good enough. #getoverit.", "I don't sugarcoat it. If you are looking for political correctness or social justice, you are on the wrong page..", "If you are going to tweet me from a block, then you are wasting my time..", "More RAGE. Ironic, you support a singer that tries so hard to look white..", "Glad these administrators realized that this safe space crap is unrealistic..", "This guy made anti-white rap lyrics. He is trash..", "All caps rage. No one is holding you back but yourself..", "Another white guilt race baiter. @RealLucasNeff.", "This guy spends too much time race-baiting. Maybe the \"POC\" actors were not good enough..", "Quit your whining. I thought you wanted a black only #safespace. #OscarsSoWhite.", "Dropped enough truth bombs for now. Going to have me some dinner..", "Just read the timeline of @joseiswriting, nothing but #antiwhite filth..", "The names #Deray and #Johnetta are just as dumb as the name Jaidrean. Even worse to be honest..", "Uh-huh, whatever you say. I would not name my kid that. I wouldn't name my DOG that. Get over it..", "Maybe the actors just aren't good enough. Stop whining. #OscarsSoWhite.", "You see, I am not silencing #BlackLivesMatter SJWs even though I disagree with what they say. I call out the hypocrisy and stupidity..", "Wants to be taken seriously. Preaches #BlackLivesMatter. Wears pants below the butt. This is DISGUSTING..", "Nate Mahaffey, stop drinking the liberal Kool-Aid..", "These #RegressiveLeft goody goody two shoes think that they can silence anyone with an opposing opinion. Not me..", "Post this to #BlackLivesMatter. The #truthhurts..", "This is what they want, black only #safespaces. Yet, they cry about not being included. #hypocrite #OscarsSoWhite.", "That movie was thug trash, it doesn't deserve anything. Stop glorifying thug culture..", "Maybe they just weren't good enough. Get over it..", "When parents give their kids dumb made up names, that only sets them up for failure..", "I don't plan on watching the Oscars anyways. Never gave a damn about it. I'm just calling out the hypocrisy of #OscarsSoWhite..", "Do this for the #NBA and #NFL, then. #hypocrite.", "#trash This crap is what is wrong with society today, glorifying thug culture. Glad it was snubbed. #OscarsSoWhite.", "&lt;---Look at the crap that these degenerate thugs do and then they cry #BlackLivesMatter. Screw that..", "Boom! That account was suspended, which is a rarity for #BlackLivesMatter since they spew trash all day..", "Caption this: Look, the guy who never left the 1960s. Stupid hippy..", "Michael Brown was a thug. The truth hurts. #Ferguson.", "#MichaelMoroz proves how intolerant the #RegressiveLeft really is. Sick of this #BlackLivesMatter trash. Sick of the hypocrisy..", "#MichaelMoroz I salute your braveness. You told the truth on #BlackLivesMatter which really should be called #BlackThugsMatter..", "Exactly. It's a shame that the #RegressiveLeft is tearing down a TEENAGER for a mere opinion..", "I'm sick of #BlackLivesMatter attacking others for an OPINION. #MichaelMoroz, I stand with you all the way..", "Everything isn't racist, get over it, people. #OscarsSoWhite #BlackLivesMatter are the real racists and bigots if anything..", "Bernie Sanders’ radical past: How the Vermont firebrand started wearing a suit and gave up on tak... via.", "A Cruz supporter told me to begone, but I've just mastered the beawesome....", "H2H polls before Trump secures the nomination and consolidates the base are pointless propaganda..", "You know, I really have to wonder who in their right mind would vote for Hillary..", "Pretty busy with campaign business so won't be on much today. Good luck out there. Let's win this for America! :-).", "Politics is war without bullets. It's ugly, messy and unfair, but in the end, it works..", "Believe me, by the GE, all of the saber-rattling of the Primary season will be a distant memory and the Party will unite behind Trump..", "Rupert Murdoch understands the narrow Cruz coalition cannot prevail....", "Rupert Murdoch is a smart man and sees the inevitable....", "A Subtle Donald Trump Victory Almost Invisible to Everyone... via @thelastrefuge2 MUST READ ARTICLE.", "Absolutely DEVASTATING article exposes Cruz for the PHONY he is. MUST READ and BOOKMARK:.", "Many 'lost' voters say they have found their candidate in Trump via @YahooNews YUGE YUGE YUGE.", "Just spoke with NW Ohio Trump Campaign Chair and here's what she told me: Cruz supporters abandoning him for Trump!.", "Saying Trump will have a LANDSLIDE VICTORY is far too pedestrian. I prefer TECTONIC SHIFT. :-) @realDonaldTrump.", "Just heard from an inside source that @tedcruz supporters are abandoning him left and right and going Trump..", "Those deeply planted in The Cruz pool will remain. Those thinking of taking a dip may think twice..", "It appears the Cruz wave in Iowa hit it's apex a month early..", "Cruz's dedicated base of 6-10% will be offended by Trump's attack on Cruz and the rest will begin to doubt Cruz..", "Trump: Cruz 'Very A Nasty Guy,' 'Nobody Likes Him' - Breitbart via @BreitbartNews.", "America HOPED Obama would be COMPETENT. Trump's COMPETENCE gives America HOPE. @realDonaldTrump.", "Minnesota: Family of 3 Found Dead – “allah akbar” and “Submit to Allah” Messages Found.", "Missouri: Muslim immigrant arrested for extortion, stalking – accused of Ansar al….", "Virginia: 1 Homegrown, 1 Muslim Immigrant Arrested Trying to Join ISIS Terrorists.", "Muslim group forces Pakistani officials to drop law banning child marriage calling it “un-Islamic” #sgp #sharia #a4a.", "Denmark reports surge in women being sexually assaulted by Muslim refugees #sgp #tcot #a4a #LEO.", "Video: Turkey's Islamic Supremacist Cult Operating Charter Schools Across U.S. #tcot #a4a #edu #lnyhbt.", "Sick Truth Behind #Canadian School Kids Singing Muslim Song #cdnpoli #tcot #a4a #sharia.", "Obama grants clemency to 7 Iranian criminals in U.S., drops charges on 14 more.", "CAIR-like group forces Pakistani officials to scrap law banning child marriage.", "Pentagon Sends Obama Plan to Close Gitmo, Move Jihadis to US Soil.", "U.S. Christian Groups Support Muslim Refugees, Ignore Persecuted Christians #tcot #a4a #lnyhbt.", "Terror-aiding @Facebook bans Czech anti-Islam pages, leaves anti-Jew &amp; pro-jihad incitement pages #LEO #tcot #lnyhbt.", "Texas: Muslim #refugee wanted to bomb malls, said \"I am against America\" #LEO #mil #tcot.", "Montreal: Muslim immigrant extorted sex from teens (ie, raped) pleads guilty to 24 charges #sgp #cdnpoli #tcot #a4a.", "Denmark reports surge in women being groped by Muslim ‘migrants’.", "Sweden Will Not Investigate Muslim Refugee Sex Assaults &amp; Police Cover-up.", "Muslim Terrorists Attack Hotel in Burkina Faso to ‘Punish Cross Worshipers’, At Least….", "Idaho: Citizens Reject Muslim 'Refugee' Invitations to Sandpoint - City Officials Ignore #tcot #a4a #leo #lnyhbt.", "Muslim Terror Groups Coordinated Attacks on #BurkinaFaso Hotel Where Hostages Being Held via @nytimesworld #jihad.", "At least 113 Muslims Indicted in Terror Plots in U.S. Since 2014 #leo #mil #lnyhbt #tcot.", "Texas high school ‘fudges truth’; teaches that under Islam, ‘all people are equal’.", "Twitter sued for allowing Islamic State to promote jihad, recruit Muslim terrorists.", "New Jersey: Does Islamic company selling ‘Sharia-compliant mortgages’ control Asbury….", "Montreal: Muslim immigrant who extorted sex from teens pleads guilty to 24 charges.", "Imam Lied About Personal Relationship with Muslim from Mosque Who Shot Philadelphia Cop #LEO #mil #tcot #a4a.", "Colorado: Terror-listed @CAIR shakes down @Cargill again, hiring policy changed for Muslim (refugees) #tcot #sharia.", "Idaho: Citizens Rejecting ‘Refugee’ Invitations to North Idaho.", "Texas: Iraqi Muslim refugee wanted to bomb malls, said “I am against America”.", "Al Jazeera America to Shut Down!.", "Facebook bans Czech anti-Islam page, leaves jihad inciters.", "NYPD submits, will pay $2M in legal fees to Muslims, remove terror report from website #LEO #FAIL.", "Maryland: Another Muslim Indicted for Joining Islamic Terrorists #LEO #MIL #tcot #a4a.", "Another fake Muslim hate crime – hijabi fined for making up attack story.", "113 Muslims Indicted in Terror Plots in U.S. Since 2014.", "Democrats (Islamic) State of the Union’s Muslim Guests.", "VIDEO: Woman Dragged SCREAMING into Subway by Muslim Refugees for #RapeJihad #sgp #tcot #lnyhbt.", "Texas-born Muslim Student Association (MSA) leader helped car-bomb U.S. #military base #a4a.", "Idaho: Muslim Refugee Gets 25 Years for Plot to Kill Americans on July 4th in Boise #leo #mil #tcot #a4a.", "Philadelphia Imam Lied About Personal Relationship with Mosque’s Devout Jihadist.", "Colorado: Terror-listed CAIR shakes down Cargill again, hiring policy changed for Muslims.", "Maryland: Muslim Indicted for Joining from al Shabaab Terror Org.", "VIDEO: Woman Dragged SCREAMING into Subway by Muslim Invaders.", "Canada: Muslims Open Fire on Popular Nightclub, Media Ignores (video) #LEO #mil #tcot #cdnpoli #a4a.", "Muslim #Refugees Arrested in Houston and Sacramento Obama Silent #LEO #MIL #TCOT #NRA.", "‘Muhammad’ baby boom in full swing in U.S. #sgp #tcot #leo (the future looks like #Cologne).", "NYPD submits, will pay $2M in legal fees to Muslims, remove terror report from website.", "Philadelphia: Muslim Cop Shooter Part of Cell, More Attacks Planned.", "Obama sends ‘High risk’ Gitmo detainee to Kuwait.", "Canada: Muslims Open Fire on Popular Nightclub (video).", "Muslim Persecution of Christians - It Has Everything to Do With Islam #tcot #a4a #lnyhbt.", "Slovakia gets it: Vows to refuse entry to Muslim migrants … #sharia #invasion.", "Canada: Terror group books \"Syrian refugee\" lecture at college, urges Muslims to do more for sharia caliphate #FAIL.", "U.S. Christian Groups Support Muslim Refugees, Ignore Persecuted Christians.", "Ireland: Pastor not guilty of ‘grossly offensive’ remarks about Islam.", "Muslim Persecution of Christians, November 2015.", "Slovakia vows to refuse entry to Muslim migrants.", "Video: Muslim Says, “Islam is coming to take over Germany...Your daughters will wear hijab” #sgp #refugees #FAIL.", "Tennessee: Nashville Opens 'Office of New Americans'...to help Muslims &amp; illegal invaders #tcot #a4a #lnyhbt.", "Most of Cologne Sex Attackers Were Newly Arrived Syrian \"Refugees\"; Police Chief Fired Over Coverup #sgp #leo #a4a.", "Another 41 (Muslim) Immigrants Snagged On Terror Charges.", "Canada: College duped – Syrian refugee lecture urges Muslims on sharia caliphate.", "‘Muhammad’ baby boom in full swing in U.S..", "Philadelphia: Muslim Attempts to Assassinate Cop, Says Did It in Name of Islam #LEO #mil #tcot #a4a #lnyhbt.", "#MLKDay He wanted us to judge people by the content of their character. That's the last thing BlackLivesMatter wants.", "O had no tears for victims in Paris or San Bernardino, but for political purposes, he's a fountain. Such a phony..", "Judging by his deals w Arab world, Obama is either the weakest, most suppliant man imaginable, or a traitor..", "Brits, if you respected the free speech of whites as you do that of Islamics, England might still be yours..", "A civilization of 1.6 billion founded entirely on hypocrisy..", "“A Communist is someone who reads Marx &amp; Lenin. An anti-Communist is someone who understands Marx &amp; Lenin.”.", "The religion of peace..", "Arab world definition of hypocrisy..", "If it hurts Americans and helps non-Americans, O is for it..", "Saudi prince chastised Trump for immigration halt while SA refuses to take one refugee, citing \"fear of terrorism.\".", "Judging by O's deals w Arab world, he is either the weakest man to ever hold high office anywhere, or a traitor..", "Pakistan just rejected a bill to end child brides - bill ruled \"incompatible w Sharia,\" \"un-Islamic,\" \"blasphemous.\".", "Iran deal: mullahs w nukes in 8 yrs so Israel will have to attack Iran 6yrs. These 2 agreed to make it inevitable..", "Iran cheated on deal, avoided new sanctions by releasing prisoners it would not have had if O was not a total putz..", "If \"often confused\" Hillary wins, her handler, Huma Abedin will be de facto leader of the [at moment] free world..", "If you react to the murders of innocents all over world w/o referencing Islam you're in PC denial, as Hillary is..", "If there's anything the left hates, it's people who think they have a right to their earnings..", "There are consequences for ignoring the Constitution for 8 yrs..", "Trump is right. We don't need this junk in USA..", "Donald Trump is a jihadist's nightmare and the jihadists know it..", "Close-up of a desk at CNN..", "Potential Leader of the Free World..", "Gun Sales Increase In Austria By 350% Due To Influx Of Migrants - ….", "If it's \"racist\" to have borders &amp; enforce immigration laws, then it's racist to have a house with doors that close..", "Obama makes Carter look like a hard-nosed realist..", "Donald Trump is a jihadist's nightmare and they know it..", "Ms. Merkel, to commemorate multiculturalism, here's a suggestion for new German postage stamp..", "Facebook punishes Westerners who agree..", "If \"often confused\" Hillary wins, her handler, Huma Abedin will be de facto leader of the [at moment] free world..", "O 2nd biggest liar in USA. (Hillary is a dynasty.).", "Carly Fiorina zings Hillary: “Unlike another woman in this race, I actually love spending time with my husband.”.", "90% of what Euro media calls RWers are regular, decent people who aren't anti minority, just anti menacing assholes..", "Ms. Merkel, to commemorate your immigration policy, suggest you use this photo for next German postage stamp..", "A few words from the Gipper..", "This is Obama-speak for, \"I did a shitty job.\".", "#OscarsSoWhite In years when a disproportional number of African American actors have been nominated I don't recall hashtag \"OscarsSoBlack.\".", "After Obama bragged about killing bin Laden last week, this happens immediately.", "Liberal host drops HARSH truth about black America everyone needs to hear.", "Despicable: Look who Iran says was CRYING when our Sailors were captured.", "135 DEAD in worst ISIS attack since Paris....", "The price of Obama's 'diplomacy:' THREE more Americans kidnapped.", "Yowza: 43% of DEMOCRATS describe themselves as....", "Mike Rowe UNLOADS surprising take on background checks (and Donald Trump).", "Sneaky: Here's how the White House is INFILTRATING your personal social media.", "Leftist European president just dropped MAJOR truth bomb about Muslim \"refugees\".", "I'd like to share possibly the most POLITICALLY-INCORRECT prayer you'll ever read.", "Liberals may IMMEDIATELY cancel their NY Times subscriptions after this gun control article.", "Brainwash: New research confirms conservatives' WORST nightmare about US colleges.", "Yikes: Look what FOOD STAMP recipients are spending their beneifits on.", "What this famous ATHEIST just admitted about Christianity Is shocking everyone.", "We just found out what Obama taught at Univ. of Chicago; it explains EVERYTHING.", "Watch: Benghazi victim's mother has BRUTAL message for Hillary after watching #13Hours.", "Obama's America: Look what students are now BANNED from doing during basketball games.", "What this American church just announced about Israel is DISGUSTING and anti-Semitic.", "DESPICABLE: what this federal court just ruled is an INSULT to every single veteran.", "BREAKING: Paris-style attack; 5 terrorists among the dead.", "Whoa: CIA director just called out Obama in a VERY LARGE way.", "Yes, I'm shocked too: there WAS some good news about Obama's #SOTU.", "And we're about to give them $150 billion. FUBAR!.", "I'll be on @TeamCavuto Coast to Coast @FoxBusiness at 12:15 ET to talk about whether we should PUNISH Iran (I know what I'd do).", "Obama REFUSED to mention one thing during last night's SOTU; here's why....", "BAM: Ted Cruz sums up SOTU in one BRUTAL sentence.", "This meme sends POWERFUL message to those offended by \"draw Muhammad\" contests.", "WOW: Almost HALF of all drivers licenses in California are going to....", "White House makes promise guaranteed to put America in DANGER.", "As secretary of state, Hillary Clinton actually contemplated this secret plan AGAINST Israel.", "Religion in the US is in decline, except for....", "New Benghazi movie leaves out one HUGE detail #13Hours.", "Yowza: What this general just said about Obama's military plan will probably get him FIRED.", "Muslim attacks Jewish teacher with machete; a MIRACLE stops the blade.", "State of the Union tomorrow: Here's ONE thing Obama won't mention (and it burns me up).", "Liberal NYC mayor \"disgusted\" by gang rape of 18-yr-old, but here's what disgusts ME.", "Stop the presses: Look how many suicide attacks were carried out by JUDEO-CHRISTIAN fanatics.", "HORRIFIC: Look how this ISIS terrorist responded when his MOTHER begged him to quit.", "New data highlights Obama \"success\" he WON'T be bragging about.", "Obama makes teary gun control speech; this happens IMMEDIATELY in California.", "New fact just learned about man arrested for terror in Texas is PARTICULARLY disturbing.", "Watch: Reporter bodyslams State Dept. official with best foreign policy question EVER.", "Oops: New email shows Hillary TOLD her staff to do something VERY un-kosher.", "'Bout time! Texas governor calls for states to join in MAJOR revolt against Obama.", "Newspaper reveals MASSIVE cover-up over Muslim \"refugees\".", "DISTURBING fact about government workers shows Trump was right all along....", "Wow: Shocking new poll has WORST POSSIBLE news for Hillary (and GOP establishment).", "Philly mayor should be REMOVED from office after this comment about Muslim shooter.", "Former Marine blasts HARDCORE open letter to teary Obama; here's why it's going viral.", "Troops are going to needlessly die because of watered down standards, altered in the name of gender equality. Not a question of if but when..", "Suddenly Buzzfeed makes a lot more sense..", "Something tells me there will be enhanced navigational training in the Navy over the coming months..", "No, let's not. Bears have to eat too, and natural selection is good for the human population as well..", "Our windchill is currently -35F. @MOfishmgr.", "This is one of those days when I really hate living in Wisconsin..", "I guarantee anyone who whines how uncomfortable it was to lay prone and shoot was a non combat arms MOS. @maxwellarm @AirForceTimes.", "Oh, I forgot. @AirForceTimes was run by Gannett, the same company that published names/addresses of gun owners..", "Good night, Twitter. Good work. Sleep well. I'll most likely kill you in the morning..", "According to the responses to this tweet, Jewish is the new black..", "I don't always take advice on transforming our economy, but when I do, it's from a freeloading 20 something millennial still living with mom.", "Hillary Clinton did surprisingly well in the #DemDebate despite downing a fifth of vodka backstage..", "You live with your parents, don't you..", "People who spent the last 8 years screaming racism at anyone who disagreed with Obama are saying race doesn't matter. That's rich #DemDebate.", "I thought you were joking. At least you admit to being a freeloader..", "Cruz and Rubio are both Hispanic. Democrat candidates are so white you need Oakley's to watch the debate..", "Party of \"If you disagree with Obama, you're racist\" doesn't like someone pointing out their candidates are white..", "Man who has been in congress longer than most millennials have been alive decries the establishment. That's rich. #DemDebate.", "My favorite part of the #DemDebate is all the diversity..", "Let women in combat arms because equality, but they only have to pass women's APFT, or its sexism. Such B.S. @ScottCFarquhar @TaskandPurpose.", "Yes it is. Enough with the selective \"equality\" and double standards..", "The Private ahead of me in line at boot cooked off a grenade. The range NCO told me he thought he was trying to kill him. @GlomarResponder.", "It's completely normal to jump directly into another persons field of fire to throw a grenade. #RedDawn.", "The dirty old COL flirting with the 18 year old girl on #RedDawn reminds me of @KurtSchlichter.", "Iran killed/injured hundreds of American troops like me. So Obama gave them billions, while he gave us shitty VA healthcare..", "Impossible. Obama said, \"Al Qaeda is on the run.\".", "Says the guy who got four deferments to avoid joining the military..", "Cruz is a terrorist from Canadastahn! If you cut him he bleeds maple syrup! He likes hockey and drinks Labatt Blue!.", "I wish I could retweet myself..", "Yes, Trump, invoke 9/11. Because the only people in America affected by 9/11 were New Yorkers..", "Pundits invoking Reagan today seem to have forgetton how he handled Iran - U.S. Sinks or Damages 6 Iran Ships.", "\"Bowe Bergdahl served with honor and distinction.\".", "Did you hear that @KurtSchlichter, we're getting sued..", "Come on, tough guy. Show your real name and face..", "Bring it on, anonymous internet tough guy..", "That makes no sense in response to what I tweeted. But here's your participation trophy for trying. @AndreaPunksmom.", "Odd. When I give New Yorkers the same smug condescension that they've given me, they think I'm an a-hole. Weird..", "If we bombed Capitol Hill you'd see the exact same thing..", "My second executive order as POTUS will be to move our nation's main New Years Eve celebration from NYC to Bangor, Maine. #Salzman2016.", "#NewYorkValues The commonly held belief that there are three Americas: New York, L.A., and @PeopleofWalmart..", "Not at all angry. I just don't take the opinions of smug, condescending ethnocentric New Yorkers seriously. @StefWilliams25.", "No, just busy not caring about your opinion. @StefWilliams25.", "I'm sorry, I was too busy clinging to my guns and religion to hear you..", "\"But you don't understand, New York really is the center of the universe!\" - People upset with me over #NewYorkValues..", "Seeing women retweet crazy stuff like \"b*tch problems\" made me realize how lucky Ive been to not date a woman who stabbed me in my sleep.", "Yeah, I had a couple rough weeks too once. I was in Iraq, getting shot at while dodging IEDs..", "\"Why Cruz's Goldman Sachs loan is a problem, but not the $225,000 speaking fee Hillary got from them.\" - Vox, probably..", "There's nothing that scares ISIS more than condemnation from the White House..", "Another VA \"success\" story, for those of you who don't know what vets have to put up with. H/t @formerlyAWTM.", "Traffic in my town is the worst..", "True. Our Navy has yet to develop the technological capabilities to operate in the dark. It's on their to-do list..", "Oh FFS. If you're seriously throwing around conspiracy theories about our sailors getting captured by Iran, go take a walk in traffic..", "An idiot urbanite raised on a diet of Walt Disney movies who thinks nature is like the city zoo..", "House Reps: #Benghazi Movie Really Makes You Angry … Just Saw it - IT REALLY DOES! #tcot.", "Death List And IRS Ravage 'Women of Bill Clinton' Likely a TRUE 'Conspiracy Theory' #tcot.", "Islamist Running 140 Tax Funded Charter Schools in USA Incremental National Suicide. #tcot.", "Trump: We're Going to Protect Christianity Well, #Obama Certainly Hasn't/Won't #tcot.", "Iran Vows to Push on W/Missile Program After US Sanctions Delivery System For Nukes #tcot.", "Have NO CONFIDENCE #Obama Intends to Lift a Finger to Protect US From Cyberattack. Biggest Concern: Power Grid #tcot.", "#Bill: Forever Taking Credit for: Economic Policies Gingrich FORCED on Him; The Tech Boom; The Peace Dividend. #tcot.", "#Obama's NOT a Coward on Islamic Extremism. He's a Sympathizer of Their Cause Who's Facilitating Their Rise With His Inaction. #tcot.", "NO ONE IS RESPONSIBLE FOR THE SINS OF THEIR FATHERS! Believing Otherwise Leads to an Endless Cycle of Violence/Tragedy #tcot.", "The Most Racist People in The World Are Islamic Extremists/Their Supporters + NOT Those That Condemn Their Pathological Intolerance. #tcot.", "Obama Takes Credit For 'Smart' Diplomacy on Iran Capitulation Isn't My Idea of 'Smart' #tcot.", "'World is Safer Today' My View: Deal Doesn't Prevent Iran Getting Nukes, it ENSURES it #tcot.", "ISIS Beheads 150 People After Taking Syrian Town Humanity Must Dispose of This Vermin #tcot.", "Britain: Muslim MP Vows to Tear Trump's Rep to Shreds My View: A Trump Endorsement. #tcot.", "#Obama Knows EXACTLY What He's Doing. His Policies Are Designed to \"Fundamanetally Transform\" USA Into 3rd World Nation #WakeupAmerica #tcot.", "We Shldn't Just Screen For Terrorism, But ALSO For Sharia-Adherence - Which is Antithetical to US Constitution #tcot.", "USA Immig Policy: Serving interests of immigrants at the expense of USA National Security + American Workers … #tcot.", "Save #America: Win Pres in 2016; Undo Obama's Executive Amnesty; Close Border; No Muslim Immigration; Rebuild DOD; Welfare Reform #tcot.", "Rubio: We're Not Going to Deport 12M People … Close Border; Use E-Verify; No Welfare; They'll Have to Go Home #tcot.", "The Very Fact That Leaving Islam is a Crime Punishable by Death Tells You All You Need to Know About Islam. #ReligionofIntolerance #tcot.", "Bill Maher: 'Fantasy' to Think Refugees Will 'Fit in' … #DeathByDemocrat #tcot.", "New Committee Launches Investigation on #Hillary's Email Server Bit** Shld be in Jail #tcot.", "John Kasich: If I Get Smoked in NH, 'The Ballgame is Over' … 'The Ballgame is Over' #tcot.", "My View: Expect #Obama to 'Double Down' on Unconstitutional EOs: RE: Gun Control; Amnesty; EPA @Amador_News #tcot.", "#Hillarys Actions/Stmts Before/During/After Benghazi Shld Have Disqualified Her From Pres Run @robinhood21067 #tcot.", "#Benghazi: US Rescue Team Was on The Way, But Was Called Back … Sounds Like Treason #tcot.", "Democrats Think What's Best For #America is One Party Rule. Course, What They Think is 'Best' Gave us DETROIT! #tcot.", "STOP ALL ISLAMIC IMMIGRATION IMMEDIATELY! Zero Tolerance For Any/All Acts of Extremism; NO SHARIA LAW! #tcot.", "Any Muslim Who Thinks He'll Get 72 Virgins When He Dies, is in For a VERY BAD TIME on Judgement Day #Depraved #tcot.", "Gowdy: Witnesses Say Stand Down Order Given in Benghazi … MSM's Still Covering For 'O' #tcot.", "Too Many Bad Apples on The Tree of Islam. BAN ALL ISLAMIC IMMIGRATION! #TrojanHorseJihadis @TonyVenutiShow #tcot.", "Churchill: No Stronger Retrograde Force in The World Than Islam …… True Then, True Now #tcot.", "#Hillary: I Would Open up OCare to Illegals … … … … … Running For Hispanderer-in-Chief #tcot.", "#Hillary: Amb Stevens was in Benghazi \"By His Own Choosing\" … … … … … Reprehensible #tcot.", "Trump: #Hillary a Liar, She Lies Like Crazy About Everything … Chip Off The Old #Obama #tcot.", "Attkisson: CBS STOPPED Benghazi, Fast/Furious/ACA Investigations for Polit Reasons … … #tcot.", "German Elites Target Hate Speech After Migrant Sex Attacks … …… Merkel Has Gone Insane #tcot.", "Pelosi: Election Shouldn't be About Bill's Past Misdeeds. True, But it SHOULD be About #Hillary Enabling Bill #tcot.", "The Very Fact That Leaving Islam is a Crime Punishable by Death Tells You All You Need to Know About Islam. #ReligionofIntolerance #tcot.", "Ben Stein: #Obama 'is The Most Racist Pres in The History of America' Racist-in-chief #tcot.", "#Sanders: \"Nobody's Earned Anything in USA Except on The Backs of Others\" Marxism 101 #tcot.", "Hillary Accuses Benghazi Victims Families of Lying Tragic: Most Dems Are OK W/Making This Moral Reprobate Pres #tcot.", "#Obama: Once You Accept That He's NOT on Our Side Everything Make Sense. @politixgal #tcot ….", "Too Many Bad Apples on The Tree of Islam. Ban ALL Islamic Immigration. #tcot @lancesilver1 ….", "Europes Migrant Invasion: Merkel's Single Handidly Destroying Europe Ban Islamic Immig #tcot.", "Fiorina: #Hillary Has Escaped Prosecution More Times Than El Chapo … … 'Above The Law' #tcot.", "Judge Napolitano: '#Hillary's Legal Woes Are Either Grave or Worse Than Grave' … … … #tcot.", "How Can #Hillary Possibly Win After '13 Hours' If There's Any Justice in This World #tcot.", "Cruz: Iran Prisoner Swap 'Negotiating W/Terrorists' Makes Targets Out of US Citizens #tcot.", "Rubio: We're Not Going to Deport 12M People Close Border; Use E-Verify; No Welfare; They'll Have to Go Home #tcot.", "Cruz: Only Reason Sailors Were Seized by Iran is Obama's Weakness Projects Weakness #tcot.", "Under #Obama, The Possibility of Martial Law Alarms Forensic Profiler Manchurian Pres #tcot.", "Forensic Profiler: #Obama Revealed Thru Iran Deal 'a Destructive Rage Beyond Belief' … #tcot.", "I Left Clinton WH When #Hillary Hired Secret Police to Dig up Dirt on Bill's Victims … #tcot.", "Forensic Profiler: Obama 'Totally Submissive to ISIS' Traitor-in-Chief #ManchurianPres #tcot.", "'13 Hours' Review: Riveting Indictment of #Obama, Hillary + MSM DEPRAVED INDIFFERENCE #tcot.", "2 Former Fed Prosecutors Expect Charges Against #Hillary on 'Emailgate' … … JUSTICE #tcot.", "Dem Panic: #Hillary's Catastrophic Collapse in 1 Chart Dishonest; Corrupt; Incompetent #toct.", "a Man is 'Only as Good as His Word', Then #Obama is 'Good For Nothing'. @ElianaBenador #tcot.", "USA Committing Hari-Kari: RE: #Obama's Unilateral Gun Control, S. American/Syrian Immigration @RKBA2015 #tcot.", "#Obama Never Intended to be Honest/Transparent. 'Hope + Change'/'Great Uniter' Were BS Lines to Get Elected. #tcot.", "Jindal: Arrest Mayors of Sanctuary Cities as Accessories to Crimes Aiding/Abetting. #tcot.", "#ISIS: Difficult For Decent Human Beings to Grasp/Wrap Their Heads Around The Absolute Evil of Jihadsim. #tcot.", "Armed Citizenry: W/The Threat of Jihadism Growing Exponentially in USA, We Need to be Able to Defend Ourselves #tcot.", "If America Had Educated/Informed Citizens, #Obama's Pres Campaign Wld Have ENDED With His 1st Primary in 2008. #tcot.", "Giuliani: We're More at Risk Now Than in Sep 2001 PC Approach to Jihadism is Suicidal #tcot.", "Save #America: Win Pres in 2016; Undo Obama's Executive Amnesty; Close Border; No Muslim Immigration; Rebuild DOD; Welfare Reform #tcot.", "Stealth Jihad is Moving Through The West PC/Ostrich Approach to Jihadism is Suicidal #tcot.", "#Hillary Faces a Relentless Trump The Right's 'Pitt Bull' is Going For The Jugular. #tcot.", "In Negotiating Prisoner Swap, #Obama Blinked on New Sanctions An Excuse to 'Blink' #tcot.", "Netanyahu: Iran Still Intent on Getting Nukes Despite Nuke Deal My View: And Use Them #tcot.", "#Hillary: NON EXISTENT MORAL COMPASS. A Far Left 'Ends Justify Means' Lowlife #tcot.", "Islam: Find it Impossible to Conceive of a Universe Where God Requires The Murder of Infidels/Treatment of Women as 2nd Class Citizens #tcot.", "#Obama Knows EXACTLY What He's Doing. His Policies Are Designed to \"Fundamanetally Transform\" USA Into 3rd World Nation #WakeupAmerica #tcot.", "We Shldn't Just Screen For Terrorism, But ALSO For Sharia-Adherence - Which is Antithetical to US Constitution #tcot.", "USA Immig Policy: Serving interests of immigrants at the expense of USA National Security + American Workers … #tcot.", "If a Man is 'Only as Good as His Word', Then #Obama is 'Good For Nothing'. @ElianaBenador #tcot.", "Dem Panic: #Hillary's Catastrophic Collapse in 1 Chart Dishonest; Corrupt; Incompetent #toct.", "2 Former Fed Prosecutors Expect Charges Against #Hillary on 'Emailgate' … JUSTICE #tcot.", "Mrs.Bill Clinton says Police Depts should reflect the race makeup of the community they serve. Baltimore PD did and it didn't stop the riots.", "Support for @realDonaldTrump does NOT make a conservative an apostate. It's that blind loyalty to GOP has brought them little since Reagan..", "Punishing soldiers who put their lives in the line for a mistake but no accountability for Obama/Clinton on Benghazi.", "Mrs. Bill Clinton said last week that \"police violence\" is terrorizing communities. Black sub culture violence is..", "Aristotle said a man is what he continually does. In this case, a criminal..", "As an outsider, this is how I see the Twitter wars going on over the GOP primary. Can it be put back together by Nov.", "Waiting to hear from GOP in Congress who think this is a great idea. Speaker Ryan wants to work with Obama on this..", "I wish GOP Congress would stop buying the myth of the non violent drug offender in prison. Shameful..", "@charlescwcooke hits it out of the park on the limits of technology and this fairy tale concept. Reliability is key..", "That Senate GOP would confirm a race demagogue to the federal bench is remarkable when Dems declined to approve Bork.", "Speaker Ryan wants to work with Obama to pass bills they agree on like sentencing reform after Obama has side-stepped Congress for 7 years..", "We have heard a lot from the left about creating \"safe spaces\". This is my definition of a \"safe space\".", "Obama is failing miserably at his most solemn duty which is to protect the American People, not gun confiscation..", "Again, I want to hear from GOP lawmakers in DC who are drinking the Kool Aid on lib soft-on-crime sentencing reform..", "Because Obama doesn't believe in freedom. He believes in government control..", "I want to hear from GOP advocates in Congress for this inane policy of sentencing reform. Blacks bear consequences..", "Like I said, the American people do not care about this BS in the DC bubble. Only political and media elites do..", "Mrs. Bill Clinton says \"police violence\" is terrorizing communities. This pandering wench is unworthy to be POTUS..", "Mrs. Bill Clinton says police violence terrorizes communities. Says nothing about, gang or drug related violence..", "Mrs. Bill Clinton calls police use of force \"police violence\", but says nothing about black on black violence..", "SOTU address is for elites. Average American does not care about that BS. I didn't watch. What I read about is why @realDonaldTrump leads..", "Watch for her next desperate move before long which is to offer to forgive college loan debt to drive youth vote..", "The destructive ideology of modern liberalism maintains the American ghetto in attempt to create future Dem voters..", "Imagine that. Obama lying again to the American ppl. Good decision by @NRA not to attend. This was a political IED..", "But the Feds won't spy on Islamic extremists using social media. Don't want to offend Muslims. I'd pay for that spy..", "Ben Carson on Powerball: ‘I Already Won the Lottery, I Was Born in America and Know the Lord’ by @MichelleFields.", "‘American Pie’ Singer Don McLean Arrested on Domestic Violence Charge.", "Hillary Clinton Praises Youtube Star Who Called Christian Woman ‘Crusty Old Homophobic B*tch’.", "Trump speaks at Liberty University: \"We're going to protect Christianity\".", "Pamela Geller: ‘The nation that gave the world the Magna Carta is dead’.", "Teacher pleads guilty to sexual misconduct--but sues the student's mother for defamation!.", "The 10 funniest moments of last night's Democratic debate: by @joelpollak.", "Glenn Beck apologizes for repeating an Anti-Trump hoax on Fox News.", "Rapist Afghan migrant sends teenage Austrian girl to hospital; he assaulted her in a public park:.", "EXCLUSIVE–Linda Tripp: ‘Bill Had Affairs with Thousands of Women’.", "Wasserman Schultz Denies DNC Is Attempting to Limit the Audience of Its Own Debates by @jeff_poor.", "IOWA READERS: Join @mboyle1 and @aswoyer as we discuss Capitol Hill and the 2016 Election..", "South Carolina–Rick Santorum tells the Tea Party: ‘Don’t act out of anger’ by @aswoyer.", "Remember: That snow y see out of your window is a thing of the past by @JamesDelingpole.", "Americans Freed from Iran–But at High Cost by @joelpollak.", "Rubio: We’re Not Going to ‘Round Up and Deport 12 Million People’.", "Watch: NBC Shows Hillary Clips of Iowa Dems Saying They Don’t Trust Her.", "Glenn Beck Apologizes for Repeating an Anti-Trump Hoax on Fox News.", "I've been falsely accused of calling for an assassination! by @Nero.", "Jada Pinkett Smith Suggests Minorities Boycott Oscars over All-White Acting Nominations.", "Leading Muslim Scholar: Gender Equality Is Against Islam; Women Are Only Fit to Deliver Children.", "CIA Spox: ’13 Hours’ Benghazi Movie a ‘Shameful’ ‘Distortion of the Events’ by @dznussbaum.", "OMG: BuzzFeed employees can't get an explanation for why “co-workers keep disappearing.”.", "EXCLUSIVE–Linda Tripp: ‘Bill Had Affairs with Thousands of Women’.", "Trump: Cruz is a \"nasty guy,\" \"total hypocrite,\" suggests some of his fundraising violates the law....", "Sheriff: A Gun in Your Hand Sure Beats ‘a Cop on the Phone’ by @AWRHawkins.", "NEW VIDEO: Our Big Hollywood review of '13 Hours: The Secret Soldiers of Benghazi'.", "Rapist Afghan migrant sends teenage Austrian girl to hospital; he assaulted her in a public park:.", "Peter Schweizer: Clinton Cash Still Rolling in for Bill’s Pardon of Fugitive Marc Rich.", "Shock: Palestinian Terrorist Breaks into Home, Murders Israeli Woman in Front of Her Children.", "Czech President: ‘It’s Impossible to Integrate Muslims into Western Europe’ by @sunsimonkent.", "Hillary: ‘I’m Just Too Busy’ to Watch the Benghazi Movie ’13 Hours’.", "Jeb sounds... confident..", "Cruz: Only Reason Sailors Were Seized by Iran Was ‘Because of the Weakness of Barack Obama’ by @pamkeyNEN.", "OMG: BuzzFeed employees can't get an explanation for why “co-workers keep disappearing.”.", "NEW VIDEO: Cologne Sexual Assault Victim Called A Racist And Harassed After Identifying Her Attackers.", "- @tedcruz is not impressed with the Iran prisoner swap.", "- @realDonaldTrump Makes A Bold Superbowl Prediction.", "Michelle Malkin dropping some bombs on Rupert Murdoch and Fox News:.", "Thank you to everyone who came to the We Are Breitbart meetup in Austin, Texas!.", "Iowa Governor: Trump Could Bring a Lot of New People Just Like Obama in 2008.", "Anne Hathaway Defends Jennifer Lawrence’s Diva Outburst at Golden Globes.", "Mo Brooks: Obama the Most ‘Racially Divisive’ President Since Civil War by @jeromeehudson.", "'13 Hours' Review: Riveting Indictment of Obama, Hillary, and the Mainstream Media by @NolteNC.", "Saudi paper says that Iran \"effectively kidnapped\" Obama himself:.", "Climate alarmists are now trying to say that satellites are lying about the temperature: by @JamesDelingpole.", "\"The white man's 15 minutes are up.\" --primetime TV exec.", "Obama Blames ‘Talk Radio Habits’ and ‘Trolling’ for the Rise of Donald Trump.", "Democrat Congresswoman gets a popular online game shut down by crying harassment: by @LibertarianBlue.", "Walmart Closing 269 Stores Worldwide–with 10,000 Layoffs in the U.S..", "Gay porn star says he's voting for Trump, 'Operation Chaos' style:.", "Hillary 2.0 Is Sinking Faster Than in Her 2008 Campaign by @flynn1776.", "Study: Fourfold Increase in Risk of Female Genital Mutilation in U.S. Due to Immigration.", "15 Year Old Boy Stabbed to Death by Arab Migrant Because He Was Protecting Young Girl from Sex Assault.", "YouTube Star Asks Obama How to Stop ‘Bullies with Badges,’ Cops with a ’Superman Complex’.", "Julia Hahn: Maria Bartiromo Drills Rubio on Wanting to Replace American Workers with Foreigners.", "A folk singer from Portland is going to sing Islamic prayers of peace in Syria. That'll show the Islamic State!.", "Vanity Fair: the two men who have \"irrevocably\" changed American politics:.", "Apple: um, no, we don't need diversity quotas on our board, thanks, bye..", "Welp, someone's filed a lawsuit to say Ted Cruz isn't natural born:.", "The director of 'Birdman' and ‘The Revenant’ ‘pities’ Donald Trump: ‘So rich, so bitter’.", "Austria Now Offers Sharia-Compliant Bank Accounts by @NickJHallett.", "“Mr. Trump would like all Americans to know the truth about what happened at Benghazi,”.", "Gay porn star says he's voting for Trump, 'Operation Chaos' style:.", "'DROP DEAD, TED': New York Daily News Gives Ted Cruz the Finger.", "Climate alarmists are now trying to say that satellites are lying about the temperature:.", "The Episcopal Church cannot represent Anglicanism in the U.S. anymore, thanks to its promotion of same-sex marriage.", "Police Take Credit for Tarantino’s ‘Hateful Eight’ Box Office Crash.", "Obama: ‘Michelle Would Kill Me’ if I Ran for a Third Term.", "Obama Admin Defends Iran: No Geneva Convention Violation.", "German Gun Sales and Permit Applications Soar After Cologne Sex Attacks.", "Democrat Congresswoman gets a popular online game shut down by crying harassment: by @LibertarianBlue.", "NEW VIDEO: Hollywood, guns, and the Golden Globes.", "Iowa Ground Game: The Inside Story of How Conservatives Have Crushed the Establishment in 2016 by @PatrickHowleyDC.", "Jeb! makes a decent point: Net neutrality is DC bureaucrats using a 1934 law to regulate the Internet.", "Nancy Pelosi: I Can See Iran from Bahrain (120+ Miles Away).", "Ann Coulter: Nikki Haley's ‘a Bimbo’ — ‘Accidentally Elected Because She’s Pretty’ by @pamkeyNEN.", "Mike Tyson Rooting for Trump, Hillary ‘in the Finals’ by @magnifitrent.", "Benghazi Families Push Back Against Clinton for Calling Them Liars.", "Planned Parenthood is suing the organization behind the sting videos exposing its baby organ harvest.", "The Empire Strikes Back--Against Ted Cruz.", "Bombshell analysis from @joelpollak: the \"only logical possibility\" is our sailors were ordered to surrender to Iran.", "Massive Food Stamp Increase for Able-Bodied Adults Without Dependents.", "Obama Frees 10 Guantánamo Detainees in Largest Recorded Single-Day Release by @JordanSchachtel.", "Nikki Haley Praised by White House, Bush, Ryan, McConnell, Consultants, and Dean Obeidallah by @NeilMunroDC.", "Al Sharpton Blasts ‘Fraudulent’ Progressive Hollywood over All-White Oscar Nominees.", "Christian Persecution Reaches Global Historic High, Thanks to Rise of Radical Islam by @Donna_R_E.", "Chris Christie: We Won’t Win by Telling People Not to Be Angry.", "Today's liberals explicitly reject the idea that all men, and women, are created equally free and independent. #tcot @PennsylvaniaGOP.", "The members of the legislative and executive branches #should, at fixed periods, be reduced to a private station and return to the people..", "Today's liberals view our morals and laws as nothing more than tools by which to advance their agenda. #tcot @SenatorRisch.", "To understand the liberal mind we must understand that today's liberals value the pursuit of power over the pursuit of truth..", "In this YouTube video we find Obama claiming that he's visited 57 states: #tcot @RepGuthrie.", "The fact that the truth may sometimes be uncomfortable must not lessen our commitment to it. #tcot @DanPatrick.", "Article 3, Section 3: Treason against the states united is #defined as levying war against them or giving aid and comfort to their enemies..", "The term 'Constitutional Order' seems to be a useful term for contrast against the chaos sought by today's liberals. #tcot @Raul_Labrador.", "Where Money Makes No Difference: #tcot @MichelleFields.", "Article 6: Members of the US government's legislative, judicial, and executive branches are bound by oath to support the Constitution..", "The last major hurricane to hit Florida, Wilma, struck about nine years ago. #tcot @RepTomReed.", "I still don't think people really understand how delusional Obama actually is. #tcot @RepLynnJenkins.", "Hussein Obama's personal jihad against Western civilization is destined to fail. #tcot @LarryOConnor.", "There is no such thing as a \"democratic\" socialist, @DailyCaller #tcot.", "Same #commie drivel that's been out there for 150 years, @WalshFreedom; #BolshevikBernie's just not really that creative. @ktb_gop #tcot.", "Here we find Jeff Jarvis calling out Obama's abject failure: #tcot @RepGoodlatte.", "The ideology of liberalism depends upon an ever-shifting mirage of conjured illusions. #tcot @TeamCornyn.", "Let's pretend this didn't happen: #tcot @CongHuelskamp.", "Arm yourself with liberty's longbow: #tcot #pjnet #tgdn.", "From worship of the self extends the entire ideology of liberalism. #tcot @SenTomCotton.", "Recognizing our own ignorance of the unseen complexities around us is an important awareness associated with the argument for liberty..", "More Obamacare mayhem: #tcot @SteveDaines.", "Tolerance and truth are irreconcilable. #tcot @NRSC.", "Despite the prophecies of climate fortune-tellers like @EzraKlein, there has been no warming in 19 years:.", "Hostile ideologue, @NYTimesKrugman, attacks Republicans and Conservatives: #tcot @RebeccaforReal.", "Nothing says #DC cartel like undisclosed loans from @GoldmanSachs and @Citibank. #tcot.", "The ideology of liberalism claims that fantasies of 'change' offer a legitimate alternative to law, order, stability, and prosperity..", "Constitution: In all cases affecting ambassadors, and those in which a state is a #party, the Supreme Court shall have original jurisdiction.", "Today's liberals perpetuate the delusion that destruction of the current order will somehow magically regenerate human nature..", "More chaos and mayhem from illegal aliens: #tcot @RepAdrianSmith.", "The House of Representatives shall be composed of members chosen every second year by the people of the states. #tcot @RepDavid.", "Another failed climate prophecy from the @nytimes: #tcot @RepFredUpton.", "Sometimes conservatives forget that their commitments to #honor and truth are easily turned against them by those not sharing those values..", "Even if we feel stressed by new competitors in the free market, we #should realize that better ways of doing things are usually positive..", "Slice through the illusions conjured up by clowns like Bill Maher and Jon Stewart: #tcot #pjnet #tgdn.", "Today's liberalism is a totalitarian ideology whose adherents harbor no qualms about selectively using science to their advantage..", "The conflict with liberalism is, first and foremost, a psychological war. #tcot @Governor_LePage.", "While liberty is #compatible with restrictions upon certain actions, liberty is not present where authorization is required more than not..", "The unstated objective of today's liberalism is the overthrow of our Constitutional order. #tcot @BeckyQuick.", "The story of Anthropogenic Global Warming (AGW) is a story of science fiction. #tcot @PatrickMcHenry.", "More savage sexual violence by illegal aliens: #tcot @GOPWhip.", "Liberal values are not American values. #tcot @PAGOP.", "Another failed climate prediction by the man-made global-warming fortune-tellers:.", "The failure to prove man-made global warming over the last 20 years makes the case for it even less plausible. #tcot @Rep_Hunter.", "Liberals tend to think that imagination and intentions are legitimate substitutes for reality and consequences. #tcot @CathyMcMorris.", "More disease imported by illegal aliens: #tcot @SoutherlandFL02.", "Temper tantrums seem to be the most common expression of the childish nature of the liberal mind. #tcot @RepErikPaulsen.", "Here we find marxist ideologue @CassSunstein fear mongering from the altar of man-made global-warming:.", "Yet another example of a liberal lie: #tcot @McCaulPressShop.", "The individualist conception is similar to chemistry in the sense that the whole is made up of many parts, such as individual atoms..", "The ideology of liberalism is an ideology of lies. #tcot @LtGovTimGriffin.", "Today's liberals imply that the overthrow of our Constitutional order will somehow magically regenerate human nature..", "If Floyd Corkins, Chris Dorner, and Aaron Alexis are any indication, today's liberals are #becoming increasingly aggressive and violent..", "Collectivists assert that #society is a creation of the legislator's genius and magically exists apart from the individuals who comprise it..", "Over the long term, all forms of collectivism depend upon plunder and require certain people to decide who gets what, when, and how..", "A brief introduction to the extortionist tactics that illegal aliens are attempting to use against us:.", "If today's liberals will callously murder the unborn, they'll have no qualms about viciously attacking anyone else. #tcot @IndGOP.", "We always need to keep in mind that today's liberals don't care about truth and they don't care about Constitutional order..", "Congress is empowered to exercise exclusive legislation over the district that is seat of the government of the United States..", "The gift of liberty is the gift of a better way of doing things. Learn it, live it: #tcot #pjnet #tgdn.", "More insight into the violence perpetrated by illegal aliens: #tcot @RepDLamborn.", "Hordes of foreigners invading Atlanta schools: #tcot @RepPaulCook.", "Since civilization's #institutions, such as liberty, can be hard to understand, it is not surprising that some get the itch to attack them..", "Constitution: Civil officers of the US, including the president, will be removed from office upon conviction for high #crimes &amp; misdemeanors.", "Obama's 1/2 brother, Malik, is active in the Muslim Brotherhood and is headed for a terrorist watch-list in Egypt. #tcot @FloridaGOP.", "Sometimes we forget that liberals' accusations of sexism and racism are mainly #conjured up to manipulate the emotions of women and blacks..", "Climate fortune-tellers fooled again by Antarctic sea ice: #tcot @RepDougCollins.", "On 12/15/10, Border Patrol agent Brian Terry was murdered by illegal aliens using AK-47s given to them by Obama's criminal regime..", "Yet another democrat attempting to subvert the Constitutional order of the United States:.", "If we had to #wait until things could be made available for everyone, even the relative comfort of today's poor could have never happened..", "Here we find marxist ideologue @CassSunstein fear mongering from the altar of man-made global-warming:.", "While our limited intellect quickly comprehends usefulness, the complexities of judging merit make it #impossible to be judged correctly..", "Obama's war on the middle class hits your electric bill: #tcot @HeatherChilders.", "Congress has the power to make all needful rules and regulations respecting the territory or property belonging to the states united..", "The religion that is today's liberalism is built upon an overly optimistic false interpretation of the true nature of mankind..", "Homosexual sodomy was a capital crime under Roman law. #tcot @RepGaryMiller.", "Although Marxism is revolutionary and Fabianism gradualist, the centrally controlled system that each envisions is basically the same..", "The ideology of liberalism is an ideology of nonsense. #tcot @JohnKasich.", "Here we find Obama praising the anarchists of the \"Occupy\" insurrection: #tcot @VirginiaFoxx.", "Alan Keyes calls out Obama as a radical communist: #tcot @RepTomMarino.", "Despite liberals attempts to confuse the two, we need to keep in mind that science and fiction are two very different things..", "There's no question that Obama is a delusional marxist and a menace to mankind. #tcot @ToddRokita.", "According to some estimates, around $12 billion per year is wasted on educating illegal aliens in US schools. #tcot @RepScottRigell.", "In free-markets and free-enterprise, efficiency trumps merit. #tcot @RepTimMurphy.", "Today's liberals falsely claim that the US was founded upon secular values rather than Christian / Roman values. #tcot @NationalDebt.", "Fact: It is a felony to aid, abet, or entice a foreigner to illegally enter the United States. #tcot @RepDonYoung.", "Twisting #liberty's definition from 'minimized coercion' into 'removed obstacles' is the basis for replacing liberty with centralized power..", "I think we can all agree that Obama is the problem. #tcot @MarioDB.", "In this YouTube video, we find Obama seeking higher electricity prices to attack the middle class:.", "The @GOP should be more aggressive at calling out Obama for being derelict in his duty. #tcot @RosLehtinen.", "Deceit and deception are two of the key tactics employed by the charlatans preaching man-made global-warming:."] 
    build_source_texts( corpus_list )
    texts
  end
  
  def source_texts( client )
    
    @texts = []
    
    tweets = []
    tweets << client.search("from:fedupwithpccrap -rt", result_type: "recent").take(100)
    tweets << client.search("from:mitchellvii -rt", result_type: "recent").take(100)
    tweets << client.search("from:creepingsharia -rt", result_type: "recent").take(100)
    tweets << client.search("from:FiveRights -rt", result_type: "recent").take(100)
    tweets << client.search("from:AllenWest -rt", result_type: "recent").take(100)
    tweets << client.search("from:jrsalzman -rt", result_type: "recent").take(100)
    tweets << client.search("from:JohnFromCranber -rt", result_type: "recent").take(100)
    tweets << client.search("from:SheriffClarke -rt", result_type: "recent").take(100)
    tweets << client.search("from:BreitbartNews -rt", result_type: "recent").take(100)
    tweets << client.search("from:LibertySeeds -rt", result_type: "recent").take(100)
    tweets.flatten!

    ## Build corpus
    corpus_list = []
    tweets.each do |tweet|
      text = tweet.text
      next if text[0] == '@'
      next if text[1] == '@'
      next if text =~ /\?/
      next if text =~ /\n/
      next if text =~ /\=/
      words = text.split(' ')
      next if words.size < 5
      text = text.gsub(/https:\/\/[\w\.:\/]+/, '').squeeze(' ')
      corpus_list << "#{text.strip}."
    end
    
    build_source_texts( corpus_list ) 
 
    texts
    
  end
  
  def parse_text( corpus, category, keyword )
    m = corpus.match( / #{keyword} /i )
    if m
      location = corpus =~ /#{keyword}/i
      return false if location < 15
      return false if (corpus.size-location < 15)
      
      words = keyword.split(' ')
      if words.size == 1
        @texts << SourceText.new({
          first_part: "#{m.pre_match}#{m.to_s}".strip,
          second_part: "#{m.post_match}",
          category: category
        })
      elsif words.size == 2
        @texts << SourceText.new({
          first_part: "#{m.pre_match} #{words[0]}".strip,
          second_part: "#{words[1]} #{m.post_match}",
          category: category
        })
      else
        return false
      end
      
      return true    
    end
    false
  end
  
  def build_source_texts( corpus_list )
    
    corpus_list.each do |corpus|
      
      ###############################
      ## Zeta - OFFICIAL
      ###############################
      category = "zeta"
      next if parse_text( corpus, category, "from" )

      ###############################
      ## Epsilon - OFFICIAL
      ###############################
      category = "epsilon"
      next if parse_text( corpus, category, "with" )
      
      ###############################
      ## Alpha - OFFICIAL
      ###############################
      category = 'alpha'
      next if parse_text( corpus, category, "to address" )
      next if parse_text( corpus, category, "to advance" )
      next if parse_text( corpus, category, "to answer" )
      next if parse_text( corpus, category, "to assassinate" )
      next if parse_text( corpus, category, "to attack" )
      next if parse_text( corpus, category, "to attend" )
      next if parse_text( corpus, category, "to avoid" )
      next if parse_text( corpus, category, "to battle" )
      next if parse_text( corpus, category, "to be" )
      next if parse_text( corpus, category, "to beg" )
      next if parse_text( corpus, category, "to blow" )
      next if parse_text( corpus, category, "to bomb" )
      next if parse_text( corpus, category, "to break" )
      next if parse_text( corpus, category, "to build" )
      next if parse_text( corpus, category, "to buy" )
      next if parse_text( corpus, category, "to call" )
      next if parse_text( corpus, category, "to close" )
      next if parse_text( corpus, category, "to commemorate" )
      next if parse_text( corpus, category, "to control" )
      next if parse_text( corpus, category, "to create" )
      next if parse_text( corpus, category, "to criminalize" )
      next if parse_text( corpus, category, "to cut" )
      next if parse_text( corpus, category, "to deliver" )
      next if parse_text( corpus, category, "to deport" )
      next if parse_text( corpus, category, "to destroy" )
      next if parse_text( corpus, category, "to develop" ) 
      next if parse_text( corpus, category, "to dig" ) 
      next if parse_text( corpus, category, "to drive" )
      next if parse_text( corpus, category, "to drop" ) 
      next if parse_text( corpus, category, "to eat" )  
      next if parse_text( corpus, category, "to end" )  
      next if parse_text( corpus, category, "to ensure" )
      next if parse_text( corpus, category, "to expand" )   
      next if parse_text( corpus, category, "to fight" )      
      next if parse_text( corpus, category, "to fund" )
      next if parse_text( corpus, category, "to get" )
      next if parse_text( corpus, category, "to give" )
      next if parse_text( corpus, category, "to grasp" )
      next if parse_text( corpus, category, "to have" )  
      next if parse_text( corpus, category, "to here" )  
      next if parse_text( corpus, category, "to import" )
      next if parse_text( corpus, category, "to integrate" )
      next if parse_text( corpus, category, "to join" )
      next if parse_text( corpus, category, "to judge" )
      next if parse_text( corpus, category, "to jump" )
      next if parse_text( corpus, category, "to keep" )
      next if parse_text( corpus, category, "to kidnap" )
      next if parse_text( corpus, category, "to kill" )
      next if parse_text( corpus, category, "to limit" )
      next if parse_text( corpus, category, "to make" )
      next if parse_text( corpus, category, "to mandate" )
      next if parse_text( corpus, category, "to mention" )
      next if parse_text( corpus, category, "to move" )
      next if parse_text( corpus, category, "to offend" )
      next if parse_text( corpus, category, "to operate" )
      next if parse_text( corpus, category, "to oppose" )
      next if parse_text( corpus, category, "to prevent" )
      next if parse_text( corpus, category, "to promote" )
      next if parse_text( corpus, category, "to protect" )
      next if parse_text( corpus, category, "to pull" )
      next if parse_text( corpus, category, "to punish" )
      next if parse_text( corpus, category, "to pursuade" )
      next if parse_text( corpus, category, "to quit" )
      next if parse_text( corpus, category, "to rebuild" )
      next if parse_text( corpus, category, "to refuse" )
      next if parse_text( corpus, category, "to return" )
      next if parse_text( corpus, category, "to sell" )
      next if parse_text( corpus, category, "to share" )
      next if parse_text( corpus, category, "to shut" )
      next if parse_text( corpus, category, "to spend" )
      next if parse_text( corpus, category, "to stop" )
      next if parse_text( corpus, category, "to support" )
      next if parse_text( corpus, category, "to scrap" )
      next if parse_text( corpus, category, "to understand" )
      next if parse_text( corpus, category, "to take" )
      next if parse_text( corpus, category, "to target" )
      next if parse_text( corpus, category, "to think" )
      next if parse_text( corpus, category, "to tweet" )
      next if parse_text( corpus, category, "to wear" )
      next if parse_text( corpus, category, "to win" )
      next if parse_text( corpus, category, "to work" )
      #"Obama wants to import this behavior."
      
      ###############################
      ## Delta - OFFICIAL
      ###############################
      category = "delta"
      next if parse_text( corpus, category, "will" )
      next if parse_text( corpus, category, "might" )
      next if parse_text( corpus, category, "shall" )
      next if parse_text( corpus, category, "should" )
      next if parse_text( corpus, category, "would" )
      next if parse_text( corpus, category, "could" )
      next if parse_text( corpus, category, "can" )
      #next if parse_text( corpus, category, "does" )

      ###############################
      ## Gamma - OFFICIAL last
      ###############################
      category = "gamma"
      next if parse_text( corpus, category, "because" )
      next if parse_text( corpus, category, "when" )
      next if parse_text( corpus, category, "but" )
      next if parse_text( corpus, category, "which" )
      next if parse_text( corpus, category, "while" )
      next if parse_text( corpus, category, "that the" )
      next if parse_text( corpus, category, "that they" )
      next if parse_text( corpus, category, "that a" )
      
      ###############################
      ## Omega - OFFICIAL
      ###############################
      category = "omega"
      next if parse_text( corpus, category, "who" )
      
      ###############################
      ## Theta - OFFICIAL
      ###############################
      category = "theta"
      next if parse_text( corpus, category, "is a" )
      next if parse_text( corpus, category, "was a" )
          
    end

  end
  
end