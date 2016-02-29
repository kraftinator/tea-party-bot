require 'active_support'
require_relative 'source_text'
## require '../project/bernie-bot/bernie_bot'

class TeaPartyBot

  MAX_CHARS = 140
  
  attr_accessor :texts
  
  def initialize( client )
    texts = source_texts( client )
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
    return false, "INVALID WORD COMBO: #{result}" if result =~ /but of/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /can have to/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /from teens pleads/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /it should it/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /look which all/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /might it/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /one who aren't/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /shall of/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /should do that is/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /sure which the/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /their will/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /\. to /
    return false, "INVALID WORD COMBO: #{result}" if result =~ /we should it/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /when is to/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /when here/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /when also/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /when did/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /when of/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /when was/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /when would/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /which also to/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /while is/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /while of/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /will for/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /will it be/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /will of/i
    return false, "INVALID WORD COMBO: #{result}" if result =~ /would as/i
    
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
    result.gsub!(".\".", ".\"")
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
    corpus_list = ["Both are horrible. They are all hypocrites..", "Go ahead and report me then, crybaby..", "These same #SJWs who claim that they are \"anti-racist\" and such are far more bigoted than I ever could be..", "#BoycottVariety Enough of the white shaming. Maybe the black actors just sucked. Don't do a movie about thug (c)rap..", "#Twitter censorship makes me sick. Stop protecting pedos..", "If I get banned for exposing SJW/feminist hypocrisy, I won't be coming back. I have a back up account, but I'm closing it..", "Quit playing the victim, kid..", "This is who #Twitter protects. They protect pedophiles. I don't know why the hell I continue to use this site..", "I will never understand why #BlackLivesMatter riot and loot for people that they never knew/met. That boggles my mind..", "#BlackPresidentSideEffects A destroyed country, 18 trillion in debt, political correctness galore.", "No one's forcing diversity here. #blackprivilege.", "Stop reading books then, little girl..", "That pandering, that pandering..", "&lt;---This trash actor panders to #BlackLivesMatter and spews garbage. Boycott him..", "#BoycottMarkRuffalo Not only he panders to #BlackLivesMatter, but he is anti-American and said that #Benghazi was BS. Boycott this trash..", "#BoycottMarkRuffalo Pandering to the trash \"movement\" called #BlackLivesMatter..", "If you want a reason to #BoycottHollywood, this is it..", "Screw #BlackLivesMatter. It's a trash, hate filled movement. No one should support it..", "And these IDIOTS claim that they want to be taken seriously, yet have no respect for others. Let the woman talk..", "&lt;---Trash article. More white male shaming. This is not fighting for \"equality' as you #SJWs say..", "Another white guilter cuck. He just wants minority supremacy, not \"equality\"..", "Wrong, if anything the #BlackLivesMatter guys that are super entitled. Just shut up and go away already..", "Good for #Denmark. Now it's time for the rest of the west to follow suit. These #rapefugees are nothing but bad news. #refugeesnotwelcome.", "This is sickening. Time to stop protecting these Moslems..", "#AnitaSaarkesian if you can't handle criticism, then stop using the internet. This woman is triggered by everything it seems like. @femfreq.", "#BlackLivesMatter wants black supremacy, they don't want this \"equality\" that they are whining about..", "Stupidity at it's finest. Maybe it's time for certain people to #obeythelaw..", "No, send them back to their own countries. #nomoreillegals.", "No, it's a privilege, not a right..", "Ah, I see, another white guilt loser who thinks that all whites are racist. Nothing new to see here..", "&lt;---Hey @MarkRuffalo, I will never praise this anti-white \"movement\"..", "Oh man, @fedupwithpccrap is triggering those #SJWs again. Now another one sent their followers after me. #triggered.", "Justin Trudeau is destroying Canada. #FeminismIsAwful.", "Rob, you spoke the truth to the idiot Bernie voters. They think that only the rich's taxes would be raised. WRONG!.", "If you #SJWs and #feminists can't handle criticism, maybe you shouldn't dish it out and NOT expect criticism..", "&lt;---This is going too far. This censorship must be stopped..", "This is for every #SJW and #feminist. Stop playing the victim..", "I'm so sick of these #SJWs blaming their problems on everything and everyone but themselves..", "They only create MORE problems. The good thing: Many people are waking up and saying \"enough\"..", "I see that POS @sacca is reporting people and getting them banned. He needs to grow up and realize that not everyone shares his views..", "Your ice cream sucks and you are a piece of trash..", "It is so sickening that many shows and movies force their liberal views on their viewers. This is why I #BoycottHollywood..", "This is for every #SJW..", "This is definitely a #waronwhites. I am so sick of this crap. I have NOTHING to be ashamed of. NOTHING..", "Another TV show for this white man to avoid even though I wasn't plan on watching anyways..", "Trump just shot @FoxNews in the middle of 5th Avenue....", "Roger Ailes responds to the Trump boycott....", "Trump just turned a boring 7th debate into the political theater of the campaign..", "FoxNews can't say Trump wasn't going to do the debate because of Kelly because he was THERE to do the debate..", "I've added 120 followers since Trump announced his boycott. The base is JAZZED about this!.", "If you don't think @FoxNews and the @RNC are freaking out about now, you'd be wrong..", "Sheriff Joe Arpaio to Endorse Donald Trump in Iowa via @NYTPolitics.", "The MAIN debate just became the KIDDIE debate..", "Trump's timing is brilliant. Just as interest in the debates is fading, Trump pulls out the last remaining reason to watch it at all..", "Hard to say Trump \"looks weak\" raising money for wounded warriors..", "This whole debate cancellation is the optical equivalent of REAGAN FIRING THE AIR TRAFFIC CONTROLLERS. #badassery.", "Thank God I don't have to live-tweet that whole damned debate..", "And tonight, there is JOY in TRUMPVILLE..", "I believe Trump would have still done the debate even with Kelly there, but @FoxNews overplayed their hand and gave Trump an excuse..", "And the Academy Award for BIGGEST BALLS IN A POLITICAL CAMPAIGN goes to Donald Trump for his brilliant boycott of the @FoxNews #debate..", "Only Trump could turn a 7th and BORING debate into the GREATEST POLITICAL THEATER of the entire campaign..", "“He’s definitely not participating in the Fox News debate,\" Lewandowski said. \"His word is his bond.\".", "To be a great negotiator, occasionally you have to make good on a threat. Trump just scored about a million TOUGH GUY CREDS on this..", "Corey Lewandowski confirmed to The Washington Post that Trump would \"definitely not\" participate in Thursday's Fox News debate..", "Trump said, \"most likely\" won't do it. So possible he still will but he is gonna demand terms..", "And just like that, Trump became THE STORY leading up to Caucus Day. He just opened the airlock and vented the entire #MOPe into space..", "Reince Priebus is passing a bowling ball about now..", "Just like the Devil, @FoxNews overplayed their hand..", "By not attending, Trump turns the entire @FoxNews #debate into the KIDDIE TABLE..", "You gotta admit, all this drama is pretty fun..", "Looks like I'll be live-flipping-off the debate and live-tweeting Trump's Town Hall..", "Trump could do a Wounded Warrior Telethon..", "All of my followers are WELL-INFORMED and GOOD LOOKING! :-).", "Reince Priebus is on the phone with Ailes right now - \"Ok dammit, pull Kelly and apologize to Trump!\".", "I promise you, they are PANICKING at FoxNews right now..", "But it's not even about @megynkelly anymore, it's about @FoxNews being arrogant jerks to the Republican frontrunner! Well played Mr Trump..", "Right now advertisers are on the phone with @FoxNews - \"CANCEL MY ADS, CANCEL MY ADS!\".", "FoxNews gave Trump the out he needed to dump the debate without looking weak. Instead of running from Kelly, he is standing up to Fox!.", "Here's the GREAT thing. Trump can now say he is boycotting the debate NOT because of Kelly, but because @FoxNews were assholes. PERFECT!.", "Roger Ailes is staring at his TV set - \"OMG, he's really gonna do it. SH*T!!!\".", "Trump pissed off by FoxNews snarky press release today may REALLY skip debate and raise money for wounded warriors instead!.", "EXACTLY! You get it..", "When Trump said he LIKES Pelosi, he means he thinks he can get her to do what he wants..", "In a good NEGOTIATION, there isn't one winner and a bunch of losers - there is one BIG winner and a bunch of LITTLE winners..", "Trump does not believe, \"giving it your best\" is enough. Unless you win, he believes it was all pointless..", "Face it, debates have become SNOOZE-FESTS. This whole Kelly drama business is just Trump making it interesting..", "If I had a dollar for every time the #MOPe declared Trump finished, I could afford to stay in a Trump Hotel..", "Remember folks, Trump thinks STRATEGICALLY, not LINEARLY. What may not make sense now will seem brilliant once we see all the pieces..", "I'm betting Trump does the debate (he wins every one) and gives his most STATESMANLIKE performance yet..", "By taunting FoxNews, he is forcing them to come out as more and more obviously biased against him. It's brilliant..", "Look back over this election cycle. Trump has negotiated with ENEMIES at every turn and ALWAYS WON. Every single time..", "Great negotiation takes more than knowledge, it takes instinct learned over decades - knowing where to push and where to let off. It's art..", "A good negotiator shows you how it is in your own best interest to let them win..", "Trump plays to win. He expects to win. He'll settle for nothing less than win..", "Trump says, \"Let me show you how helping us win helps you win...\".", "The only negotiations which require no give and take involve guns..", "Britain: Muslim no-go zones emerging in Bury Park, Luton (video) #immigration #sharia #fail.", "Idaho: Muslim yogurt billionaire will hire more Muslim #refugees - not Americans; urging other Co's as well #FAIL.", "Wisconsin Manufacturer Won’t Negotiate with Terrorist-linked CAIR.", "The Origins &amp; Connections of the Clinton’s First White House Ramadan Dinner.", "Muslim invaders to receive extra benefits for multiple wives.", "Days after Muslim tried to kill Philly cop for Allah, City Council backs 2 Muslim holidays.", "Lawmakers File Bill \"To Stop Islamic Religious Indoctrination In Tennessee Schools\" #tcot #edu #lnyhbt.", "Video: Tactics for the Counter Jihad #leo #mil #tcot #a4a #lnyhbt.", "Idaho: Muslim yogurt billionaire: ‘Hire more Muslim refugees’.", "Philadelphia: After Muslim tries to kill cop for Allah, City Council backs two….", "Britain: Muslim no-go zones emerging in Bury Park, Luton (video).", "2015 Deadliest Year for Christians Worldwide, Muslim Nations Dominate List of Persecutors #tcot #lnyhbt #.", "Filipino Christians Form Militia To Fight Islamic State #mil #leo #tcot #lnyhbt.", "Toronto: Immigrant Imam tells Muslims only hire, do biz w Muslims – never the kafir #cdnpoli.", "A Gruesome Christmas under Islam.", "2015 Deadliest Year for Christians Worldwide, Muslim Nations Dominate List.", "Islamic State razes ancient Iraq monastery.", "Filipino Christians Form Militia To Fight ISIS.", "Video: Muhammad and the Origins of Islam #jihad #sharia #leo #mil.", "Seattle Muslim admitted killing 4 Americans as \"vengeance\" for Muslims, was on terror list.", "Video: Tactics for Counter Jihad.", "Obama releases al Qaeda's most skilled explosives expert to (Clinton's Muslim) Bosnia #FAIL.", "Toronto: Imam tells Muslims only hire Muslims; only do business with Muslims – never the kafir.", "London: Muslim school caught with books promoting stoning people to death.", "The Islamization of France in 2015.", "Video: Ex-Muslim Turned Biker's Powerful Message To Muslims in America #mil #tcot #leo #nra #a4a.", "Man who threatened to kill NYPD &amp; Philly cops pledged allegiance to ISIS #leo #tcot #mil #lnyhbt.", "Seattle Muslim who killed 4 Americans as “vengeance” for Muslims, sentenced for robbery.", "Lawmakers File Bill “To Stop Islamic Religious Indoctrination In Tennessee Schools”.", "Video: Ex-Muslim Turned Biker’s Powerful Message To Muslims in America.", "Obama releases al Qaeda’s most skilled explosives expert to Bosnia.", "Texas high school teaches blatant LIE that under Islam, ‘all people are equal’ #sgp #tcot #a4a #lnyhbt @ConroeISD.", "Wisconsin: Company gave Muslim refugees prayer breaks &amp; mini mosque...then production &amp; morale dropped #sharia #FAIL.", "Georgetown Professors Team Up With Suspected Muslim Brotherhood Front Groups #leo #tcot #a4a #lnyhbt.", "Ex-con who threatened to kill NY, Philly cops pledged allegiance to ISIS.", "Ohio: FBI probes Kent State professor for ISIS ties.", "Minnesota: Family of 3 Found Dead - \"allah akbar\" and \"Submit to Allah\" Messages Found #leo #FAIL.", "US Embassy confirms \"several\" Americans missing in Baghdad, Iranian Militia Suspected #tcot #mil #Obama #FAIL.", "Wisconsin: Muslim prayer breaks result in declining production, company now has to….", "Philadelphia: Muslims Want Two Paid Islamic Holidays Added to City’s Municipal Calendar.", "Islamic Kuwait Air Halts New York Flights Rather Than Allow Jews to Fly.", "Missouri: Muslim immigrant arrested for extortion and stalking terror-linked Muslims who took him in #LEO #tcot #a4a.", "Virginia: 2 Muslims Arrested Trying to Join ISIS Terrorists #leo #tcot #immigration #FAIL.", "Kansas City Imam Explains Abrogation in Islam (video).", "US Embassy confirms “several” Americans missing in Baghdad, Iranian Militia Suspected.", "Georgetown Profs Team Up With Suspected Muslim Brotherhood Front.", "Video: The Legacy of Arab - Islam in Africa (ie, Slavery) #MLKNOW #sharia.", "Black Africans forced to learn Arabic, women treated like 2nd class citizens under Islamic #sharia in Mali #MLKNOW.", "Pentagon Sends Obama Plan to Close #Gitmo By Moving Jihadis to US Soil #LEO #MIL #TCOT #A4A #LNYHBT.", "Minnesota: Family of 3 Found Dead – “allah akbar” and “Submit to Allah” Messages Found.", "Missouri: Muslim immigrant arrested for extortion, stalking – accused of Ansar al….", "Virginia: 1 Homegrown, 1 Muslim Immigrant Arrested Trying to Join ISIS Terrorists.", "Muslim group forces Pakistani officials to drop law banning child marriage calling it “un-Islamic” #sgp #sharia #a4a.", "Denmark reports surge in women being sexually assaulted by Muslim refugees #sgp #tcot #a4a #LEO.", "Video: Turkey's Islamic Supremacist Cult Operating Charter Schools Across U.S. #tcot #a4a #edu #lnyhbt.", "Here's childish Fox \"news\" release that made Trump say screw Fox. (reportedly written by Roger Ailes himself).", "Saudi prince railed at Trump for immigration halt while SA won't take a single refugee, citing \"fear of terrorism.\".", "Yes multiculturalism enriches us all..", "Biggest protest in history of Poland (anti Muslim immigration). European &amp; US media pretended it never happened..", "To avoid \"racism\" (&amp; truth) German TV calls Muslim criminals \"southern appearance people.\" Zero description Sweden..", "If you're a female who favors Muslim immigration, maybe watch this. It's happening all over Europe right now. … ….", "Megyn Kelly's a bimbo using Trump to get herself more famous, same as Dan Rather/Nixon..", "Saudi prince railed at Trump for immigration halt while SA won't take a single refugee..citing \"fear of terrorism.\".", "More proof that multiculturalism enriches us all..", "Her every career opportunity &amp; bit of fame came from marrying the right man. Feminists should be embarrassed by her..", "Mayor Belgian town wants migrants banned from pub pool after girls as young as 11 harassed.", "10 British schools evacuated due to bomb threats..", "#WordsThatDontDescribeHillary a woman of integrity.", "Euro media too gutless to call Muslims \"Muslims,\" though it's what they call themselves. It's like refusing to call Americans \"Americans.\".", "If you're a female who favors Muslim immigration, maybe watch this. It's happening all over Europe now. ….", "To avoid \"racism,\" German TV calls Muslim criminals \"southern appearance\" people. Sweden won't describe them at all..", "Saudi prince railed at Trump for immigration halt while SA won't take a single refugee, citing \"fear of terrorism.\".", "Euro media still covering up migrant crimes, even in Cologne..", "I didn't make meme, but I have to agree with it. Pro-Muslim double standard is absurd. Either censor all or none..", "Sessions: How Obama abuse of temp visa laws is sneaking Muslims USA (censored by Facebook)..", "SO full of crap..", "Saudi prince railed at Trump for immigration halt while SA won't take a single refugee, citing \"fear of terrorism.\".", "Rudy Giuliani says Hillary Clinton can't avoid indictment in email scandal. ….", "17yo girl raped, 14yo sister sexually assaulted by Muslim migrants at German public pool. ….", "And the hand delivering the sack of money does it with Obama's blessing..", "Sure, lots of American, free-speech-loving Christians say this..", "Hillary Clinton has told criminal lies in every decade of her adult life (prob as a child too; it's who she is)..", "Yes multiculturalism enriches all our lives..", "PCness stems from fear of being called a racist &amp; no one is more gutless than TV, so TV has 1 narrative: the minority is the victim, always..", "Sweden: migrant tries to rob elderly person, hits mom who tried to help victim. Video..", "Germany to issue new postage stamp celebrating multiculturalism..", "Hillary Clinton has told criminal lies in every decade of her adult life (prob as a child too, it's who she is)..", "Saudi prince railed at Trump for immigration halt while SA won't take a single refugee, citing \"fear of terrorism.\".", "When Repubs accuse Trump of having \"no core values,\" it's because he's pragmatic &amp; not dogmatic..", "They said we shouldn't admit 300k people who hate us so I said, \"That's not who we are,\"- and it shut them right up!.", "Cartoon exposes BRUTAL truth about money Obama is giving to Iran.", "Now we know: Here's the REAL reason refugees are flooding Europe.", "#OscarsSoWhite meme has liberal heads EXPLODING.", "Here's why Jerry Falwell's endorsement of Trump doesn't matter.", "ISLAM takes over Europe: Look what Italy and France are doing for it now....", "BREAKING: Indictment in Planned Parenthood video case....", "3rd grader tries to shut down Trump's immigration stance with RACIST argument.", "Danny DeVito thinks #OscarsSoWhite proves THIS about America.", "ABC tries to attack Trump, but outright LIES to its viewers about this....", "Bernie SLAMS Uber, but look what we found....", "Hilarious! Look which demographic Hillary is losing NOW.", "Here's the HUGE question to ask yourself before you decide who you want for president.", "Folks, you're MISSING the point about Michael Bloomberg running for president.", "Video of this woman is liberals' WORST nightmare - and she's going viral.", "Who Bill Maher blames for #OscarsSoWhite is making liberal heads EXPLODE.", "Obama's America: Look what happens to a basketball team that's \"too good\".", "Breaking: BOMB threat on flight from this US city....", "Horrific: Look why this English town is now the MURDER capital of Britain.", "Meme explains BRUTAL truth about a President Bernie.", "Christian man risked his life to flee Muslim persecution only to have THIS happen....", "Chilling: ISIS warns of new plan to INVADE this country....", "After Obama lets in thousands of refugees, here's EXACTLY what happens next....", "Top conservative magazine attacks Trump; BACKFIRES big time.", "Mr. President, you need to explain this...RIGHT NOW.", "Liberal filmmakers go to Muslim refugee camp; this happens IMMEDIATELY.", "Islamic shooter storms classroom; teacher responds INSTANTLY.", "I'll be on @Varneyco this morning 11am ET @FoxBusiness . Tune in if you can!.", "Liberals TRIED, but they couldn't stop THIS happening at Chick-fil-A.", "NFL star making $48 million has THIS to say about the American Dream.", "This chart DESTROYS #OscarsSoWhite premise.", "Thugocracy: Yet ANOTHER Obama administration official may face criminal charges.", "First Chelsea Handler - now ANOTHER famous liberal is slamming PC speech.", "Whoa: Look who's pushing \"Obama is a Muslim\" theory now.", "BAM: College president shows EXACTLY how to deal with students protesting\"racist food\".", "SICK: What Democrats in the Senate just blocked puts us ALL at risk.", "HUGE: ISIS deals terrible blow to Christianity; world silent.", "UNREAL: Look what Muslim leader blames for mass sex attacks in Germany.", "Even during the prisoner swap, Iran was plotting THIS behind our backs.", "Sniper kills insurgent but is instantly in trouble for INSANE reason.", "OUTRAGEOUS: Look what deserter Bergdahl is STILL eligible to receive.", "Here's a top 10 list CAIR DESPERATELY wants to hide.", "Never mind Walmart, look who's getting hit by minimum wage NOW.", "New intel about Iranian US boat seizure is incredibly DISTURBING.", "BREAKING: Terrorists with AK-47s kill at least 20 at university.", "SMOKING GUN: Hillary's swan song has begun with THIS new email discovery....", "What might happen to David Petraeus and NOT to Hillary Clinton is absolutely disgusting.", "Here are Hillary's 5 BIGGEST lies from Sunday's Democrat debate.", "I'll be on Your World @TeamCavuto today @FoxNews in the 4pm ET hour re: Senate voting on stricter vetting for refugees. Tune in!.", "Mexican drug lord El Chapo fears only ONE presidential candidate....", "Top Hollywood stars threaten to BOYCOTT Oscars over this....", "Yikes: Liberal comedian drops major truth bomb on NAACP, CAIR to their FACE.", "REVEALED: Here are the convicted criminals Obama just traded to Iran.", "Democrats' secret plan for Hillary is working...and people have ZERO idea.", "These 5 charts DESTROY liberal arguments for stricter gun control.", "After Obama bragged about killing bin Laden last week, this happens immediately.", "Liberal host drops HARSH truth about black America everyone needs to hear.", "Despicable: Look who Iran says was CRYING when our Sailors were captured.", "135 DEAD in worst ISIS attack since Paris....", "The price of Obama's 'diplomacy:' THREE more Americans kidnapped.", "Yowza: 43% of DEMOCRATS describe themselves as....", "Mike Rowe UNLOADS surprising take on background checks (and Donald Trump).", "Sneaky: Here's how the White House is INFILTRATING your personal social media.", "Kid, my war record is public knowledge. I'm not indulging your masturbatory fantasy of being a fighter instead of a coward @KawaiiKraken.", "Oh noes! Non white people! Quick, kid! Run to your anonymous Twitter safe zone! @KawaiiKraken.", "Kid, unlike you I have the balls to go and fight the enemy. I'm not scared of anonymous little kiddie warriors on Twitter. @KawaiiKraken.", "Thanks for proving my point, kid. You kids are cowards who are scared to even show your real name and face. @KawaiiKraken.", "Lifelong conservative - Most of Donald Trump's Political Money Went To Democrats — Until 5 Years Ago @Squeekerz76.", "Kid, when all you do is spout nonsense on Twitter from an anonymous account, you're not fighting, you're hiding. @KawaiiKraken.", "LOL. Like I said, you're cowards. You don't even have the balls to use your real name and face. You're little kids..", "It's a toss up. I'm either writing in @mikeroweworks or Bill Murray..", "While Trump didn't help 9/11 victims, he did find it in his heart to donate $100k to Hillary Clintons foundation..", "Yes, Mr. #NewYorkValues is such great guy that he didn't donate any money to charity to help 9/11 victims..", "They said the same thing for global cooling, population bomb, acid rain, global warming and the ozone hole..", "Yes, you're the epitome of the word Christian. You might be related to Jesus Christ himself. @FatBrando.", "You're an angry person with no followers. No, really, you have zero..", "I'm 100% in favor of burning the Washington establishment to the ground. I'm against handing Trump the gas &amp; matches.", "I look forward to your apology to the @NRA for insinuating they're responsible for a shooting that never happened..", "I've been waiting since October for @VAMinneapolis to authorize payment for my dentist to fill my cavities. Government healthcare is awesome.", "Blames @NRA for reported shooting, challenges other people on facts. Doesn't know shooting never actually happened..", "Finally got around to fastening the battery pack for the heater I built into my prosthetic arm..", "This is amazing. The water is poisoned due to government incompetence, and he bitches about companies donating water.", "Jerry Falwell Jr endorses greedy billionaire who only goes to church on Christmas and Easter, and collects Bibles, but doesnt read them..", "Let's see a cat do this..", "20k followers is my glass ceiling..", "It's an incredibly racist poll tax that prevents low income and minority citizens from defending themselves..", "It's amazing watching people nod in approval at Sanders' proposed tax increases because they think it will happen to everyone except them..", "Sanders needs to skip ahead to the part about gulags and wealth confiscation. #FeelTheBern.", "Or the validation of every \"anti war\" protest under Bush. Yeah, veterans haven't forgotten, you cowardly scumbags..", "How progressives feel about American troops..", "Holy hell. What an incredibly racist gun law that hits poor uneducated minorities the worst..", "According to @algore's 2006 Sundance prediction, we have two days until the planet cooks from global warming..", "Clearly you've never met some of the ladies in lumberjack sports..", "Bernie misspelled \"gun control.\" #FeelTheBern #Sanders2016.", "Log rolling is at the forefront of gender equality. Men &amp; women get paid the same. But women start on smaller logs..", "Dude. I could be the ten time men's log rolling world champion, AND the ten time women's champ and beat my sister!.", "And sexist. Pay no attention to the female country music artists who are on the radio every five minutes. @BecketAdams.", "Singer who said the same thing about Bush tries last ditch effort for publicity to escape inevitable job at Walmart..", "The fact you got angry with me bashing white supremacist, Nazi Trump supporters says a lot. @mrs_raincloud.", "Yes I did. And I'm forever grateful to all those who came together to make it happen. Can't wait to shoot it!.", "I thought white supremacist Trumpkins hid behind anonymous accounts because they're brave non PC warriors..", "They're so brave and free that every last one of them are tweeting behind an anonymous account from mom's basement..", "Apparently you can still run if you're under criminal investigation, though. CC:@HillaryClinton.", "Because there's nothing more positive than bulldozing someone's house for a limousine parking lot..", "Trump cultists are a parody of themselves..", "Wisconsin is covered in snow 4-5 months a year. Your snow photos don't impress us..", "Vox: when it's really hot out it's global warming, when it's cold and snowy it's just weather..", "Even \"ethanol free\" super or premium unleaded has ethanol in it from the sharing of tanks. Always use additive. @MOfishmgr @MikeTactical.", "How Wisconsinites see the Eastern seaboard's snow storm freak out..", "Or they've never seen what happens when you put ethanol in something with a plastic fuel tank. @MOfishmgr.", "You're right. This tweet tells me you're a lot dumber than I thought..", "Guy who has never cleaned a gummed up carburetor in his life wants more corrosive chemicals in our gasoline..", "Clearly you're not a fan of Taco Bell..", "Charlie Sheen will do the same thing if you give him a suitcase full of blow..", "Apparently Trump is one of those pro choice, pro gun control, pro government healthcare, pro eminent domain conservatives..", "Yes, it's a conspiracy theory, like the moon landing and 9/11. @NikHun.", "Step 1. Get off your lazy ass and exercise for a change instead of watching TV or wasting time on Twitter..", "It's a shame @iowahawkblog left the state before it passed..", "I went to #shotshow to cover a wounded warrior story for @NRA. Turned out I was the story..", "I'd show you the photos of me with @JennJacques at #shotshow, but as the saying goes, what happens in Vegas stays in Vegas..", "Thanks @KatiePavlich! Great seeing you again..", "Sarah Palin is the drunk obnoxious aunt who you're obligated to invite to important family gatherings..", "Odd, I don't remember it being national news last time it snowed in the Midwest..", "I will vote for the presidential candidate who vows to deport these people..", "There's a special place in hell for those who watch a movie on their iPad at full volume without headphones during a flight..", "My favorite part of @mspairport is when all the airport parking is full and you have park at a different airport and hop a train back..", "And I've spent my entire life living among \"working class people.\" Not one was a white supremacist/antisemite..", "I haven't seen this much pandering to white supremacist voters since Ron Paul was running for president..", "If you're one of those white supremacist, anti semitic types, just go ahead and use that unfollow button. My feelings won't be hurt..", "I'm not sure which is worse, the anti-semitism, white supremacist crowd, or those who try to give them legitimacy..", "This is the loser whose reckless driving killed the NCO mentioned in my previous retweet. He molested a 4 year old..", "From his press release: Trump \"will instead host an event in Iowa to raise money for Veterans &amp; Wounded Warriors\".", "Nicely done. Liberals who keep arguing Hillary did nothing wrong, please see the below:.", "That's a lot of effort by Obama's FBI and IG for someone who alleges they \"did nothing wrong.\".", "America's self appointed \"grandma\" responded by reminding him she's been doing this long before he was born. Hmm..", "Tough to argue with logic - National Review: How dare you say we endorsed McCain &amp; Romney. To be clear we endorsed... McCain &amp; Romney..", "I didn't hear any complaints from Trump critics when I said this....", "If they want to whine and cry that's fine - weird - but fine, just don't allege my facts are wrong when they aren't..", "Fact: National Review endorsed Romney in 08' &amp; McCain in 10'. Hence, they endorsed Romney &amp; McCain just as I said..", "FACT: Hillary &amp; Rubio both support child tax credit, foreign policy views on Libya (Arab Spring) &amp; immigration (Rubio flipped on refugees)..", "Benghazi survivors don't consider being lied to by Hillary her taking responsibility-I'll take their word over hers..", "It can be. You know what else seems to work: karma. You really do reap what you sow. Ultimately cream rises..", "The establishment insisted he was credible. They have a serious blindspot..", "Do as I say, not as I did..", "Attacking Trump now won't work.", "I wouldn't call this Hillary \"taking responsibility\" for Benghazi..", "It sure does. Such a beautiful pic from such a beautiful charity. @LZ_Grace.", "NR endorsed McCain for Senate over Hayworth in 10', not 12'. Their rationale wasn't true conservatism said McCarthy:.", "To Hillary, how a terrorist died is worth 200k. How four Americans died, at this point, doesn't make a difference..", "I wouldn't mock Trump supporters saying they can't read when so many never read mood of the party to see him coming..", "Weird. They asked if they can have til November 9, 2016..", "The vast, right wing Federal Bureau of Investigation..", "GOP keeps dreaming about adding millennial women &amp; Latinos. Trump adding working class voters makes more sense..", "Nobody should be getting paid to give speeches about the Bin Laden raid. Not anyone, but especially not her..", "Just posted a photo.", "Past 2 candidates weren't \"conservative\" or exciting yet establishment embraced &amp; they lost. Finally, someone electrifies &amp; they trash him..", "It's one big Dem coverup. They all knew about her server: NY Times buries the news of Clinton's classified emails.", "Trump has crossover appeal. Elites have never met a blue collar worker (unless they were fixing their jacuzzi)..", "Good luck with that. There aren't many..", "NRO ENDORSED Romney &amp; McCain &amp; gave us W's wars, huge deficits, amnesty, bailouts. They helped create Trump's rise..", "It is. William F. Buckley used @NRO to publish a stellar series of conservatives who lead to the Reagan Revolution..", "National Review has endorsed Mitt Romneycare &amp; John McCain. Movement \"conservatism\" by the elites has not worked..", "I respect @NRO but they should've blasted the SOURCE of conservatism crumbling which lead to Trump's rise: THE FAILED, ELITE ESTABLISHMENT..", "Despite refugee crisis Obama at all costs: \"I will stand w them should political winds shift in an ugly direction.\".", "The most powerful terrorist recruitment tool out there is the Obama Administration..", "\"Movement conservatism\" has not been a powerful enough force to make things better for the working classes in the US.", "Everyone is talking about this article today. Perhaps \"conservatives\" aren't as popular as they thought: @michaelbd.", "A MUST read this morning: How an obscure adviser to Pat Buchanan predicted the wild Trump campaign in 1996.", "Ironic to hear these words from the same RINO career politicians in DC who put the Republican party on life support..", "Yes. @realDonaldTrump is uniquely suited to win a bellwether, blue collar &amp; notably purple state like PA..", "You really can't make it up... New feminist dilemma: men are TOO helpful around the house.", "Even Lena knows, a woman who bullies other women bc of the pervy, wrongful actions of her husband is the worst kind..", "LOVING this book &amp; how it's enriched our daily devotionals. Thanks @rachelcw &amp; @coachkiki for the personalized copy!.", "Interesting timing Petraeus demotion talk. Sounds like a threat but it only reminds ppl that HRC must suffer, at minimum, same punishment..", "Very little, IMO. While there is some short term benefit + a dunk on Cruz, Palin needed it more than Trump did..", "100%. There isn't some guy in a room with a rubber stamp labeling emails 'classified'. Hillary knew full well..", "NYT echoes this today w piece on how even Lena Dunham \"disturbed\" by Clinton sex scandals.", "Too big to NOT jail.", "The markings DO NOT MATTER. Content of the msg is what determines its classification. Some docs are born top secret..", "Big @oreillyfactor tonight: Bill has @realDonaldTrump at the top, @13hours director @michaelbay at the end, and me in the middle..", "\"Poorly scripted\"...b/c a jihadi ambush should produce more entertaining dialogue than that Stick to covering Davos..", "This is personal. Payback for the way the establishment treated her. @SarahPalinUSA @realDonaldTrump.", "There is a pickle maker somewhere watching this Palin endorsement press conference who just found a title for his memoir: Art of the Dill.", "This is very serious. Anything less than what Petraeus received is overt special treatment for an obvious criminal..", "She's violated numerous federal laws, most serious re: espionage. FDR would've had her summarily jailed. @MaxVenator.", "If only they asked the Iranian militia group in a nicer way....", "To those who say it's \"ludicrous\" this is a version of @realDonaldTrump 's policy proposal applied to nightlife..", "Ain't that the truth..", "Funny. It was Bill who flew that flag as Gov over the state house in AK calling us \"Confederate States of America.\".", "She did. Then she covered it up. If anyone sees @13hours &amp; still votes for Hillary they're a criminal..", "She has no choice but to give full throated support for Obama to shore up left...&amp; she might need him to pardon her..", "Can't take my eyes off this live @DonaldJTrump rally..", "Left often prides itself on diversity. First candidate to be under federal investigation is certainly a new one..", "Bernie already capitulated &amp; said he's \"sick\" of hearing about Hillary's emails at first debate. He's not serious..", "Obama's soft power &amp; capitulate at all costs foreign policy has now put a bounty on the head of every American..", "While the Administration is busy celebrating the dreadful Iran deal....", "\"ISIS is not getting stronger....they have been contained\" - @BarackObama, 11/15.", "I trust @FBI Director Comey in the Clinton private server investigation. It's Obama and AG Lynch I don't trust..", "FOLKS, THERE REMAINS A GOOD CHANCE WE CAN STOP THIS INSANE GET OUT OF JAIL FREE IDEA. PLEASE CALL @SenTomCotton NOW!.", "Good for @SenTomCotton. GOP is getting ready to give away the only remaining principle they stand for. Law and order.", "I'm tired of hearing how upset GOP congressmen are. They do not care about how upset We The People are with them..", "While Bernie Sanders is relying on well, white elitist entitlement minded socialists..", "Might work for fishing, not at all when capturing crooks regardless of how liberals spin it..", "Look at this Sander's event. All \"old white guys\". The same lack of diversity libs criticizes GOP candidates over..", "Libs look down on these Americans as compared to someone with a useless degree in Gender or African-American studies.", "Locked, loaded, ready for listening. New People's Sheriff podcast is posted. Not for faint of heart. No sacred cows..", "President Obama held a staged Town Hall on guns because he fears he is not equipped to have a debate based on facts..", "Keynote speaker Black&amp;Blue Ball. North California chapter of COPS-Concerns of Police Survivors President Susan Moody.", "Typical. DC is run by liberals who cannot do for self and wilt at any sign of adversity. Even gov couldn't handle it.", "Once again a low level non violent drug offender given many second chances in an \"evidence based program\", kills..", "McConnell should have refused to bring racist fed judge Wilhelmina Wright's nomination up for vote until Reid yielded on Syrian refugee vote.", "Minority leader Harry Reid beats McConnell and GOP controlled Senate. Reid plays chess as McConnell plays checkers..", "Mrs Bill Clinton's claim that police need to be \"retrained\" is not supported by her rhetoric.", "Why I went off on GOP Senate confirmation vote. Capitulated again. No fight..", "THAT'S IT. I AM THROUGH WITH GOP SENATE. LET DEMS TAKE IT BACK IN NOV. THEY KNOW HOW TO USE POWER. WHY TRUMP LEADS..", "Mrs.Bill Clinton says Police Depts should reflect the race makeup of the community they serve. Baltimore PD did and it didn't stop the riots.", "Support for @realDonaldTrump does NOT make a conservative an apostate. It's that blind loyalty to GOP has brought them little since Reagan..", "Cruz challenges Trump to a one-on-one debate:.", "Hillary: Nominating Obama to the Supreme Court ‘Great Idea’ — ‘I Love That’.", "Report: Donald Trump ‘Definitely Not’ Doing Fox News Debate.", "Billionaire-blasting Bernie's unreported ties to George Soros.", "Town demands written essay on why you want to exercise your 2nd Amendment rights before you can exercise them:.", "Millennials tell Hillary what they REALLY think:.", "Academy Defends Diversity Purge: ‘We Are Not Excluding Older Members’.", "Reddit Mods Censor Story of Refugee Center Worker Stabbed to Death by Migrant.", "Sony is spinning off PlayStation into a separate business entity by @get2church.", "FBI Declares Arbitrary Halt to Background Check Appeals by @AWRHawkins.", "RIP Abe Vigoda.", "Rubio: Ted Cruz ‘Feeling the Pressure’ Against Donald Trump.", "Rep Introduces Bill Declaring Obama’s Gun Control ‘Null And Void’ in Kentucky.", "Billionaire-blasting Bernie's unreported ties to George Soros.", "Standing Ovation at Sundance for Pro-Abortion Documentary.", "Report: Iran Is the World’s Leading Executioner of Children by @JordanSchachtel.", "Rand Paul may return to the main stage in future GOP debates: by @MichelleFields.", "Jerry Falwell Jr. Endorses Donald Trump.", "Shock Poll: Ted Cruz Plummets with White Evangelicals; Trails Donald Trump by 17 Points.", "Israeli Jew in German Refugee Camp Encounters Swastikas and Anti-Semitic Slurs.", "A monster story ignored by the MSM: FBI Declares Arbitrary Halt to Background Check Appeals by @AWRHawkins.", "Sweden’s Army Chief Warns of World War III Inside Europe ‘Within a Few Years’ by @oliver_lane.", "Boston Globe Endorses John Kasich.", "Ted Cruz Lowers Expectations in Iowa by @flynn1776.", "#JeSuisMilo Is a Tipping Point for Twitter by @Doc_0.", "Four weeks on from Cologne, the media is still hiding details of migrant assaults: by @oliver_lane.", "Twitter Can Only Fix Its Problems if It Returns to Its Roots by @LibertarianBlue.", "Maker of Oreos, Ritz Crackers Shedding Thousands of Chicago Jobs, Outsourcing to Mexico.", "Trump Hires Top Aide from Jeff Sessions’ Office.", "Lawsuit Alleges Disney Conspired to Replace American Workers with Foreigners.", "Ben Carson campaign counting on a 'secret weapon' in Iowa by @aswoyer.", "Tea Party Founder: Why I Support Donald Trump for President.", "Perez Hilton Shames Bethenny Frankel for Wanting English-Speaking Kmart Employees: ‘You Should Vote for Trump’.", "San Francisco’s Biggest Taxi Biz Goes Bankrupt by @AdelleNaz.", "Hillary has a coughing fit in the middle of a campaign speech:.", "Christian Refugees in Turkey Hide Their Religion in Fear by @mchastain81.", "Donald Trump reviews his stay at @HIExpress -.", "Donald Trump explains how he defines conservatism.", "Obama thinks this person is \"wicked smart\" -.", "\"Donald Trump I believe is a very dangerous man.\".", "Lena Dunham has a list of words that you shouldn't use to describe Hillary -.", "WATCH: Breitbart Editor @RaheemKassam Debates ‘Racist Wristbands’ On Sky News.", "Five reasons to suspect Democrats are on the verge of attemption gun confiscation by @AWRHawkins.", "Phyllis Schlafly’s Eagle Forum predicts ‘National Review will be defunct in the next year'.", "Rick Perry announces his presidential endorsement:.", "SPOILER: New Anthony Weiner Documentary Backed by George Soros.", "RandcPaul: Trump’s ‘Delusions of Grandeur Have Him Saying He Can Shoot People’ by @pamkeyNEN.", "Atlanta Paper Epitomizes Gun Grabbers’ Thought Process In 2 Sentences Back-to-Back by @AWRHawkins.", "If you're a migrant man in the UK, it really pays to have multiple wives:.", "Breitbart News Executive Chairman, Editor-in-Chief apologize to Washington Free Beacon, Michael Goldfarb.", "Over the east coast's snowed in weekend, Chicago got a storm of shootings--20 victims, with 4 killed..", "David Brooks: ‘I’m Telling You It’s Going to Be Rubio’ — ‘Do Not Panic’ by @jeff_poor.", "Marines Reject Southern Teen because of Confederate Battle Flag Tattoo.", "WATCH: Migrant attacks mother and children after being caught trying to rob an elderly woman.", "Laura Ingraham Blasts National Review for Damaging GOP’s 2016 Campaign with Anti-Trump Tirade.", "Disgraced Weiner Says Michael Bloomberg Could Win the White House.", "Iowa GOP Chairman: Party Will Support Donald Trump ‘One Thousand Percent’ if He Wins Nomination.", "Hillary says her speaking fees are high because Osama Bin Laden.", "‘It’s F—ing Knee-Jerk Liberalism’! Academy members aren't too keen on the Oscars diversity purge:.", "Franklin Graham addresses Wheaton's support of a professor who said Muslims &amp; Christians worship the same God..", "Clinton Ally David Brock: The GOP Nominee Will Be Donald Trump.", "Atlanta Paper Epitomizes Gun Grabbers’ Thought Process In 2 Sentences Back-to-Back by @AWRHawkins.", "Joni Ernst Plans Rally with 'Strong Conservative' Rubio in Iowa.", "Egypt Allows University to Ban Niqab-Covered Professors by @mchastain81.", "Donald Trump takes credit for Bernie Sanders' surge over Hillary:.", "Katrina Pierson vs Cruz Spox: You Focus On Trump’s Positions 15 Years Ago, but 15 Years Ago Cruz Was a Canadian.", "Donald Trump: Ted Cruz’s Eminent Domain Attack Ad ‘False Advertising’.", "Don Cheadle: I Want Chris Rock to ‘Take Everybody to Task’ for ‘White Oscars’.", "Laura Ingraham Blasts National Review for Damaging GOP’s 2016 Campaign with Anti-Trump Tirade.", "Paris Terrorists: ‘With Allah’s Help We Will Liberate Palestine’.", "Franklin Graham calls out Wheaton's support of a professor who said Muslims &amp; Christians worship the same God..", "Marines Reject Southern Teen because of Confederate Battle Flag Tattoo.", "If you're a migrant man in the UK, it really pays off to have multiple wives:.", "Cruz: No Actual Voters Ask About the ‘Silly Birther Attack’ by @pamkeyNEN.", "Fox News poll says Trump has surged 11 points in Iowa over the last two weeks..", "David Brooks: ‘I’m Telling You It’s Going to Be Rubio’ — ‘Do Not Panic’ by @jeff_poor.", "Glenn Beck Administers ‘Presidential Oath of Office’ to Ted Cruz in Iowa.", "Hillary says her speaking fees are high because Osama Bin Laden.", "Franklin Graham addresses Wheaton's support of a professor who said Muslims &amp; Christians worship the same God..", "Why liberals are smarter than conservatives..", "Rubio Says He Won’t Reveal His Position on TPP Until After the Primaries.", "Macklemore admits his place in #BlackLivesMatter is to nod in agreement–but ends up rapping about it for 8+ minutes..", "Oscar-Winning Producer to #OscarsSoWhite: ‘Stop Acting Like Spoiled Brats’.", "Mike Huckabee: God Will Judge Ted Cruz’s Christian Faith by @aswoyer.", "LISTEN: Macklemore's terrible, horrible, no good, very bad ode to white privilege: by @jeromeehudson.", "#OscarsSoWhite Wins: Academy to Purge Old Members for ‘Diversity’.", "Jonah Goldberg: Trump was ‘up until 3 AM tweeting like a little girl’ about National Review by @pamkeyNEN.", "VIDEO: Iraq War Veteran Transforms Wheelchair into Snowplow to Help Community.", "We should be more aggressive at calling out the destructive, divisive, class-warfare tactics of @SenWarren. #tcot @SenPatRoberts.", "#Trump is no liberal, @redsteeze #tcot.", "Ugly history of racism threatens to further undermine liberal media flagship: #tcot @RepMikeRogers.", "Hussein Obama's personal jihad against Western civilization is destined to fail. #tcot @Heritage_Action.", "If one thing is for certain, it's that Obama is a delusional lunatic. #tcot @Jim_Jordan.", "#Trump is no dummy; this is a very smart move on his part. For myriad reasons. @slone @NPJules #tcot.", "The band of swindlers over @nro is mostly interested in feeling good about themselves rather than conserving anything of actual value. #tcot.", "Seems like the band of swindlers over @nro are seriously under-estimating the appeal of #Trump on #border security. #tcot #Trump2016.", "Those who seize the opportunities afforded by liberty also have a moral obligation to address directly resulting negative #consequences..", "The ideology of liberalism includes the notion that stories suffice for truth. #tcot @SenToomey.", "Ditched my #TV and #cable service some 15 years ago. One of the best decisions I've made. #tcot.", "Jeb should stop wasting everyone's time: #tcot @TomLatham.", "Seal the #borders, raid the mosques. @DavidHazelwood4 @RonPaul #Trump2016.", "The ideology of liberalism claims that fantasies of 'change' offer a legitimate alternative to law and order. #tcot @DanPatrick.", "It's rather baffling that anyone trusts the band of #swindlers over @nro. #tcot.", "Yet another failed climate prophecy: #tcot @DesJarlaisTN04.", "The ideology of liberalism insists that moral superiority depends upon nothing more than self-proclamation. #tcot @RepDennisRoss.", "Really prefer @TedCruz on #SCOTUS or as #AG, though. @Brian_Casserly @brithume @FoxNews.", "#Cruz is my #2, as you know, @Brian_Casserly; if #Trump goes down, I'm happy to vote for @tedcruz @FoxNews @brithume.", "If today's liberals will callously murder the unborn, they'll have no qualms about denying health-care to veterans. #tcot @FrankDLucas.", "#Trump is the strongest on fighting back against the illegal aliens invasion and that's the top issue for most people, @SteveDeaceShow #tcot.", "Once you #recognize that liberals have no interest in truth, or the pursuit of truth, it becomes easier to fight their duplicitous agenda..", "Seal the #borders, raid the mosques. #Trump2016 #tcot.", "More savage violence by illegal aliens in the \"sanctuary state\" of Maryland: #tcot @RonPaul.", "I guess #journalism really isn't your thing, @brithume #tcot.", "If the #borders aren't sealed and the mosques aren't raided, nothing else is going to matter. That's what @nro doesn't understand. #tcot.", "Marxist agitator @RBReich pulling in $240,000 per year from Cal-Berkeley: #tcot @RepKinzinger.", "Talk about #boring ....", "The ongoing invasion of the United States, by illegal aliens, is the #1 issue and #Trump is far and away the #strongest on that issue. #tcot.", "Trump's by far the strongest on protecting born #children from the illegal alien invaders and jihadists, @KatiePavlich. Seal the #borders..", "He's always good for a laugh, @Tbradshaw15.", "Climate fortune-teller Daniel Schrag prophesies that 13-foot storm surges will be normal on the East coast by 2050. #tcot @DesJarlaisTN04.", "Here we find marxist democrat Louis Michael Seidman attacking the United States Constitution: #tcot @TomRooney.", "The individualist conception is similar to chemistry in the sense that the whole is made up of many parts, such as individual atoms..", "Interesting perspective on western #Europe, from the perspective of a #Russian: #tcot.", "While conservatives tend to value truth, they must better recognize that the rest of the world does not. #tcot @MIGOP.", "It will be interesting to see how this plays out, @RoxyShores, @DanScavino @RealSheriffJoe @realDonaldTrump @FoxNews.", "Earliest South Carolina snow on record threatens to discredit global-warming hoaxer @EzraKlein: #tcot @Rep_Hunter.", "In 2007, a fortune-teller named Al Gore conjured up the notion that the polar ice caps would disappear by 2014:.", "At the heart of America is not the toxic ideology of liberalism but the stability of Constitutional order. #tcot @VoteTimScott.", "Despite what the polls may say, the @washingtonpost has anointed me the clear @GOP front-runner:.", "A little more about the illicit arms smuggling operation run by the Obama #regime to undermine the 2nd Amendment:.", "More insight into the savage violence imported by illegal aliens: #tcot @RepDavid.", "An inconvenient truth: More than 600,000 bats were killed by wind turbines in 2012. #tcot @DeanHeller.", "Regardless of attempts to confuse government functions with 'socialism', it's important to remember that they are not the same..", "Our Constitutional order doesn't depend upon vague fantasies of 'equality' and 'fairness', it depends upon truth. #tcot @Rep_Southerland.", "It's certainly reasonable to conclude that reduced solar activity is ushering in global cooling:.", "Today's central Pacific cyclone activity is near the lowest levels of the past 5,000 years. #tcot @RebeccaforReal.", "Today's liberals are basically a band of clever robbers. #tcot @MDuppler.", "You are a lamp of liberty, a shining beacon for all to see. Glow brighter, shine bigger: #tcot #pjnet #tgdn.", "Run-of-the-mill liberals actively attempt to confuse roads and fire departments with collectivism by referring to them as 'socialism'..", "Let us choose more wisely than to choose another Bush. #tcot @KimGuilfoyle.", "Today's liberals value neither Constitutional order, nor truth. #tcot @Rep_Southerland.", "Yet another young American murdered by illegal aliens: #tcot @RepBlainePress.", "The light of liberty is each of us. Shine brighter: #tcot #pjnet #tgdn.", "In 2004, around 80% of those infected with drug-resistant TB were illegal aliens. #tcot @BeckyQuick.", "Globe greening as CO2 increases foliage: #tcot @JeffFlake.", "Anytime, anywhere, anyhow - violent criminals know no bounds: #tcot @RoyBluntPress.", "Today's liberalism is a primitive, foreign, hostile, toxic, totalitarian ideology. #tcot @CathyMcMorris.", "Correlation is not causation. #tcot @RepDennisRoss.", "Constitution - Article 1, Section 9: No tax or duty shall be laid on articles exported from any State. #tcot @SeanSpicer.", "Here we find even more evidence of illegal aliens interfering with elections: #tcot @MarcoRubio.", "Constitution - Article I, Section 7: In all such cases, the votes of both houses shall be determined by yeas and nays. #tcot @DaveReichert.", "Send them home: #tcot @SaxbyChambliss.", "The Congress and the Courts must defend the Constitutional order of the United States from a rogue executive. #tcot @RepToddYoung.", "Obama's criminal regime is offensive to the Constitutional order of the United States. #tcot @SenPatRoberts.", "The Constitution, and the laws made in pursuance thereof, are the supreme law of the land to which judges in every state are bound..", "The ideology of liberalism, in its essentials, is an attempted cultural insurrection. #tcot @RepLarryBucshon.", "Whether or not someone imposes their will upon another is an issue #far different from whether or not we can choose wisely among our options.", "Those of the liberty school know that the ideas, institutions, and traditions upon which our civilization rests were discovered over #time..", "Here we find even more evidence of illegal aliens interfering with elections: #tcot @RobWittman.", "Those who preach from the altar of man-made global-warming purposefully confuse natural climate change with man-made global warming..", "ObamaCare anything but affordable: #tcot @SalmonCongress.", "I'm still not sure if Americans understand that liberals see them as nothing more than witless cash cows:.", "Bad people tend to hide behind a mask of good intentions. #tcot @RepToddYoung.", "Collectivists assert that society is a creation of the legislator's genius and magically exists apart from the individuals who #comprise it..", "To preserve morality, liberty, and prosperity, the leaden #threads of centralized state power must be confined to the fewest possible seams..", "Those who adhere to today's ideology of liberalism claim unlimited coercive power in the name of 'public health'. #tcot @TeamMcCain.", "We should remember that the values of today's liberals have nothing in common with the values of the founding fathers. #tcot @TeamCavuto.", "Your lamp of liberty, timeless truths for today's course of human events: #tcot #pjnet #tgdn.", "According to this article, volcano emissions are actually cooling our climate: #tcot @Senate_GOPs.", "It's important to keep in mind that the story of man-made global-warming is not a story of science, but a story of science-fiction..", "To the liberal mind, an American is nothing more than someone within the geographical borders of the United States. #tcot @Bob_Casey.", "Liberals and jihadists both seem to share a visceral hatred for Christians and Christianity. #tcot @RepPaulCook.", "#Trump constantly on #offense: #tcot #Trump2016.", "Climate fortune-teller Daniel Schrag prophesies that 13-foot storm surges will be normal on the East coast by 2050. #tcot @RepBlainePress.", "Civilization faces grave danger where the angst of responsibility is transformed into hostility toward liberty. #tcot @SenatorRounds.", "Today's liberals are characterized by their hyper-active imaginations and their hyper-active emotions. #tcot @PortmanPress."] 
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
    tweets << client.search("from:WayneRoot -rt", result_type: "recent").take(100) # 9
    tweets << client.search("from:DanScavino -rt", result_type: "recent").take(100) # 13
    tweets << client.search("from:AndreaTantaros -rt", result_type: "recent").take(100)
    tweets << client.search("from:SheriffClarke -rt", result_type: "recent").take(100)
    tweets << client.search("from:BreitbartNews -rt", result_type: "recent").take(100)
    tweets << client.search("from:LibertySeeds -rt", result_type: "recent").take(100)
    
    #tweets << client.search("from:jrsalzman -rt", result_type: "recent").take(100) # Inactive
    #tweets << client.search("from:JohnFromCranber -rt", result_type: "recent").take(100) # 13
    
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
    
    corpus_list.uniq!
    build_source_texts( corpus_list ) 
 
    texts
    
  end
  
  def parse_text( corpus, category, keyword )
    m = corpus.match( / #{keyword} /i )
    if m
      location = corpus =~ /#{keyword}/i
      return false if location < 20
      return false if (corpus.size-location < 20)
      
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
      next if parse_text( corpus, category, "to allow" )
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
      next if parse_text( corpus, category, "to boycott" )
      next if parse_text( corpus, category, "to break" )
      next if parse_text( corpus, category, "to build" )
      next if parse_text( corpus, category, "to buy" )
      next if parse_text( corpus, category, "to call" )
      next if parse_text( corpus, category, "to carry" )
      next if parse_text( corpus, category, "to clip" )
      next if parse_text( corpus, category, "to close" )
      next if parse_text( corpus, category, "to commemorate" )
      next if parse_text( corpus, category, "to control" )
      next if parse_text( corpus, category, "to cover" )
      next if parse_text( corpus, category, "to create" )
      next if parse_text( corpus, category, "to criminalize" )
      next if parse_text( corpus, category, "to cut" )
      next if parse_text( corpus, category, "to deliver" )
      next if parse_text( corpus, category, "to depend" )
      next if parse_text( corpus, category, "to deport" )
      next if parse_text( corpus, category, "to destroy" )
      next if parse_text( corpus, category, "to determine" )
      next if parse_text( corpus, category, "to develop" ) 
      next if parse_text( corpus, category, "to dig" ) 
      next if parse_text( corpus, category, "to discover" ) 
      next if parse_text( corpus, category, "to discuss" ) 
      next if parse_text( corpus, category, "to donate" )
      next if parse_text( corpus, category, "to drive" )
      next if parse_text( corpus, category, "to drop" )
      next if parse_text( corpus, category, "to dump" ) 
      next if parse_text( corpus, category, "to eat" )  
      next if parse_text( corpus, category, "to end" )  
      next if parse_text( corpus, category, "to endorse" )
      next if parse_text( corpus, category, "to ensure" )
      next if parse_text( corpus, category, "to exit" )
      next if parse_text( corpus, category, "to expand" )
      next if parse_text( corpus, category, "to explain" )
      next if parse_text( corpus, category, "to fight" )
      next if parse_text( corpus, category, "to follow" )
      next if parse_text( corpus, category, "to fund" )
      next if parse_text( corpus, category, "to get" )
      next if parse_text( corpus, category, "to give" )
      next if parse_text( corpus, category, "to grasp" )
      next if parse_text( corpus, category, "to have" )  
      next if parse_text( corpus, category, "to hear" ) 
      next if parse_text( corpus, category, "to hold" ) 
      next if parse_text( corpus, category, "to import" )
      next if parse_text( corpus, category, "to integrate" )
      next if parse_text( corpus, category, "to invite" )
      next if parse_text( corpus, category, "to join" )
      next if parse_text( corpus, category, "to judge" )
      next if parse_text( corpus, category, "to jump" )
      next if parse_text( corpus, category, "to keep" )
      next if parse_text( corpus, category, "to kidnap" )
      next if parse_text( corpus, category, "to kill" )
      next if parse_text( corpus, category, "to learn" )
      next if parse_text( corpus, category, "to legalize" )
      next if parse_text( corpus, category, "to limit" )
      next if parse_text( corpus, category, "to make" )
      next if parse_text( corpus, category, "to mandate" )
      next if parse_text( corpus, category, "to mention" )
      next if parse_text( corpus, category, "to move" )
      next if parse_text( corpus, category, "to obey" )
      next if parse_text( corpus, category, "to offend" )
      next if parse_text( corpus, category, "to operate" )
      next if parse_text( corpus, category, "to oppose" )
      next if parse_text( corpus, category, "to pander" )
      next if parse_text( corpus, category, "to pass" )
      next if parse_text( corpus, category, "to pay" )
      next if parse_text( corpus, category, "to plow" )
      next if parse_text( corpus, category, "to prevent" )
      next if parse_text( corpus, category, "to produce" )
      next if parse_text( corpus, category, "to profit" )
      next if parse_text( corpus, category, "to promote" )
      next if parse_text( corpus, category, "to protect" )
      next if parse_text( corpus, category, "to pull" )
      next if parse_text( corpus, category, "to push" )
      next if parse_text( corpus, category, "to punish" )
      next if parse_text( corpus, category, "to pursuade" )
      next if parse_text( corpus, category, "to pursue" )
      next if parse_text( corpus, category, "to quit" )
      next if parse_text( corpus, category, "to raise" )
      next if parse_text( corpus, category, "to read" )
      next if parse_text( corpus, category, "to rebuild" )
      next if parse_text( corpus, category, "to receive" )
      next if parse_text( corpus, category, "to recruit" )
      next if parse_text( corpus, category, "to reduce" )
      next if parse_text( corpus, category, "to refuse" )
      next if parse_text( corpus, category, "to return" )
      next if parse_text( corpus, category, "to revoke" )
      next if parse_text( corpus, category, "to see" )
      next if parse_text( corpus, category, "to sell" )
      next if parse_text( corpus, category, "to share" )
      next if parse_text( corpus, category, "to shut" )
      next if parse_text( corpus, category, "to spend" )
      next if parse_text( corpus, category, "to stay" )
      next if parse_text( corpus, category, "to stop" )
      next if parse_text( corpus, category, "to support" )
      next if parse_text( corpus, category, "to survive" )
      next if parse_text( corpus, category, "to scrap" )
      next if parse_text( corpus, category, "to understand" )
      next if parse_text( corpus, category, "to take" )
      next if parse_text( corpus, category, "to target" )
      next if parse_text( corpus, category, "to terminate" )
      next if parse_text( corpus, category, "to think" )
      next if parse_text( corpus, category, "to train" )
      next if parse_text( corpus, category, "to tweet" )
      next if parse_text( corpus, category, "to use" )
      next if parse_text( corpus, category, "to visit" )
      next if parse_text( corpus, category, "to watch" )
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