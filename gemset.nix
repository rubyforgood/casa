{
  actioncable = {
    dependencies = ["actionpack" "activesupport" "nio4r" "websocket-driver" "zeitwerk"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1kxdc5d7iyh0fjqqxr7x2l37xp48lcdpafkvsqc0p5bc4vd3qcjp";
      type = "gem";
    };
    version = "7.1.3.3";
  };
  actionmailbox = {
    dependencies = ["actionpack" "activejob" "activerecord" "activestorage" "activesupport" "mail" "net-imap" "net-pop" "net-smtp"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qx6435q80bzk9h8hvii2vf6hq9nfb50ggm58ps8vy8jci3xh9bm";
      type = "gem";
    };
    version = "7.1.3.3";
  };
  actionmailer = {
    dependencies = ["actionpack" "actionview" "activejob" "activesupport" "mail" "net-imap" "net-pop" "net-smtp" "rails-dom-testing"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05jjaw7m6xc4lpwidpnq9pnzg4rb5ild1ivp82shr7qq7wqlixbb";
      type = "gem";
    };
    version = "7.1.3.3";
  };
  actionpack = {
    dependencies = ["actionview" "activesupport" "nokogiri" "racc" "rack" "rack-session" "rack-test" "rails-dom-testing" "rails-html-sanitizer"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "193svay7hhjxx5p42lxjwmk22hlp2bbf6b2gjb802108h0gzs29x";
      type = "gem";
    };
    version = "7.1.3.3";
  };
  actiontext = {
    dependencies = ["actionpack" "activerecord" "activestorage" "activesupport" "globalid" "nokogiri"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vg85ff59hqndwk61kd9b5y5y7vnvm85cddrbg7la4ibkwfxa87d";
      type = "gem";
    };
    version = "7.1.3.3";
  };
  actionview = {
    dependencies = ["activesupport" "builder" "erubi" "rails-dom-testing" "rails-html-sanitizer"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zfmqqxaj1qnwr2ic6z6axsg332p8msikn9phr1i9vy1lpia31fs";
      type = "gem";
    };
    version = "7.1.3.3";
  };
  activejob = {
    dependencies = ["activesupport" "globalid"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0sd2h1l3dfl66sdvwg6xm6f7hx0pyj6wsv1mdavz0gkl104r2qgg";
      type = "gem";
    };
    version = "7.1.3.3";
  };
  activemodel = {
    dependencies = ["activesupport"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0klvgx1bvr3f9l1hg5n7cdbsqzkp42dz7if82wgw9l77rhlj1j8h";
      type = "gem";
    };
    version = "7.1.3.3";
  };
  activemodel-serializers-xml = {
    dependencies = ["activemodel" "activesupport" "builder"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pk5qrxxhgxlihim8qkdk805nq584ms71hmcg1766iwhx0v2x3r2";
      type = "gem";
    };
    version = "1.0.2";
  };
  activerecord = {
    dependencies = ["activemodel" "activesupport" "timeout"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1j9m8m5y035lx2kyx04wzpspsvhadqggf4nyjlwg1xw4kpa37qrx";
      type = "gem";
    };
    version = "7.1.3.3";
  };
  activestorage = {
    dependencies = ["actionpack" "activejob" "activerecord" "activesupport" "marcel"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hm10apwx80xp8qgcsfrpx2qmsvg707vpqvdvrr0rax0zq8zs25s";
      type = "gem";
    };
    version = "7.1.3.3";
  };
  activesupport = {
    dependencies = ["base64" "bigdecimal" "concurrent-ruby" "connection_pool" "drb" "i18n" "minitest" "mutex_m" "tzinfo"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0z8kygxmz99krz9pwp947znkzf0jr64sml28df0vf1gzxlg7y57i";
      type = "gem";
    };
    version = "7.1.3.3";
  };
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0irbdwkkjwzajq1ip6ba46q49sxnrl2cw7ddkdhsfhb6aprnm3vr";
      type = "gem";
    };
    version = "2.8.6";
  };
  after_party = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11g8w209w1fzg9058j8gmfgsn26zp6zwaq4liwxyg021lpc8fmcl";
      type = "gem";
    };
    version = "1.11.2";
  };
  amazing_print = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15vklc53pgf2zr1rvncy4yz7ikm63k5ghfa2hlf425fwm8yyj0wr";
      type = "gem";
    };
    version = "1.6.0";
  };
  annotate = {
    dependencies = ["activerecord" "rake"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lw0fxb5mirsdp3bp20gjyvs7clvi19jbxnrm2ihm20kzfhvlqcs";
      type = "gem";
    };
    version = "3.2.0";
  };
  ast = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04nc8x27hlzlrr5c2gn7mar4vdr0apw5xg22wp6m8dx3wqr04a0y";
      type = "gem";
    };
    version = "2.4.2";
  };
  authtrail = {
    dependencies = ["railties" "warden"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12vnkajvszkvfg3rfbf4lkvrnml8q16jv59fagkzyaqg93kbbsmd";
      type = "gem";
    };
    version = "0.5.0";
  };
  azure-storage-blob = {
    dependencies = ["azure-storage-common" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qq3knsy7nj7a0r8m19spg2bgzns9b3j5vjbs9mpg49whhc63dv1";
      type = "gem";
    };
    version = "2.0.3";
  };
  azure-storage-common = {
    dependencies = ["faraday" "faraday_middleware" "net-http-persistent" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0swmsvvpmy8cdcl305p3dl2pi7m3dqjd7zywfcxmhsz0n2m4v3v0";
      type = "gem";
    };
    version = "2.0.4";
  };
  base64 = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01qml0yilb9basf7is2614skjp8384h2pycfx86cr8023arfj98g";
      type = "gem";
    };
    version = "0.2.0";
  };
  bcrypt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16a0g2q40biv93i1hch3gw8rbmhp77qnnifj1k0a6m7dng3zh444";
      type = "gem";
    };
    version = "3.1.20";
  };
  better_html = {
    dependencies = ["actionview" "activesupport" "ast" "erubi" "parser" "smart_properties"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1sk5s5lpwbd53s4a1xzm02nys3kfqdw5mh9i2qfn04hjsk8wk3gc";
      type = "gem";
    };
    version = "2.0.2";
  };
  bigdecimal = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gi7zqgmqwi5lizggs1jhc3zlwaqayy9rx2ah80sxy24bbnng558";
      type = "gem";
    };
    version = "3.1.8";
  };
  bindex = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zmirr3m02p52bzq4xgksq4pn8j641rx5d4czk68pv9rqnfwq7kv";
      type = "gem";
    };
    version = "0.8.1";
  };
  blueprinter = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fz2mc5wb2fgxc6bxjqj019aiyvqqdmlp3xfrfs23c7qid733ak1";
      type = "gem";
    };
    version = "1.0.2";
  };
  brakeman = {
    dependencies = ["racc"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lylig4vgnw9l1ybwgxdi9nw9q2bc5dcplklg8nsbi7j32f7c5kp";
      type = "gem";
    };
    version = "6.1.2";
  };
  bugsnag = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "149sb4fx6sq8cl6w9zv88kvl0x90cxj0hljz40226v4npyz6fmm7";
      type = "gem";
    };
    version = "6.26.4";
  };
  builder = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "045wzckxpwcqzrjr353cxnyaxgf0qg22jh00dcx7z38cys5g1jlr";
      type = "gem";
    };
    version = "3.2.4";
  };
  bullet = {
    dependencies = ["activesupport" "uniform_notifier"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zs6dwspb0m9ygl7lwdmilhdn9ka85a0qfiip49m9rfpfj46lps0";
      type = "gem";
    };
    version = "7.1.6";
  };
  bundler-audit = {
    dependencies = ["thor"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gdx0019vj04n1512shhdx7hwphzqmdpw4vva2k551nd47y1dixx";
      type = "gem";
    };
    version = "0.9.1";
  };
  byebug = {
    groups = ["development" "test"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "mingw";
    } {
      engine = "mingw";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nx3yjf4xzdgb8jkmk2344081gqr22pgjqnmjg2q64mj5d6r9194";
      type = "gem";
    };
    version = "11.1.3";
  };
  capybara = {
    dependencies = ["addressable" "matrix" "mini_mime" "nokogiri" "rack" "rack-test" "regexp_parser" "xpath"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vxfah83j6zpw3v5hic0j70h519nvmix2hbszmjwm8cfawhagns2";
      type = "gem";
    };
    version = "3.40.0";
  };
  capybara-screenshot = {
    dependencies = ["capybara" "launchy"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xqc7hdiw1ql42mklpfvqd2pyfsxmy55cpx0h9y0jlkpl1q96sw1";
      type = "gem";
    };
    version = "1.0.26";
  };
  caxlsx = {
    dependencies = ["htmlentities" "marcel" "nokogiri" "rubyzip"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06lg57d6r7dz0phj1l02nbrhnhkssisdvh65pc10qmrcszcgdl27";
      type = "gem";
    };
    version = "4.1.0";
  };
  caxlsx_rails = {
    dependencies = ["actionpack" "caxlsx"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0v5kvrk93rh58sj99hil8gkb6xbhhwcm5pp9zpffcy75wrlzr17y";
      type = "gem";
    };
    version = "0.6.3";
  };
  cliver = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "096f4rj7virwvqxhkavy0v55rax10r4jqf8cymbvn4n631948xc7";
      type = "gem";
    };
    version = "0.3.2";
  };
  coderay = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jvxqxzply1lwp7ysn94zjhh57vc14mcshw1ygw14ib8lhc00lyw";
      type = "gem";
    };
    version = "1.1.3";
  };
  concurrent-ruby = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1kmhr3pz2nmhnq0nqlicqfwfmkzkcl835g7sw1gjjhjvhz8g2sf3";
      type = "gem";
    };
    version = "1.3.1";
  };
  connection_pool = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x32mcpm2cl5492kd6lbjbaf17qsssmpx9kdyr7z1wcif2cwyh0g";
      type = "gem";
    };
    version = "2.4.1";
  };
  crack = {
    dependencies = ["rexml"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cr1kfpw3vkhysvkk3wg7c54m75kd68mbm9rs5azdjdq57xid13r";
      type = "gem";
    };
    version = "0.4.5";
  };
  crass = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pfl5c0pyqaparxaqxi6s4gfl21bdldwiawrc0aknyvflli60lfw";
      type = "gem";
    };
    version = "1.0.6";
  };
  cssbundling-rails = {
    dependencies = ["railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nzp4j1ll6llgbrvqk81gkz6fqgk33sx4k1fcvbm7v7h79jk8808";
      type = "gem";
    };
    version = "1.4.0";
  };
  csv = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zfn40dvgjk1xv1z8l11hr9jfg3jncwsc9yhzsz4l4rivkpivg8b";
      type = "gem";
    };
    version = "3.3.0";
  };
  database_cleaner-active_record = {
    dependencies = ["activerecord" "database_cleaner-core"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12hdsqnws9gyc9sxiyc8pjiwr0xa7136m1qbhmd1pk3vsrrvk13k";
      type = "gem";
    };
    version = "2.1.0";
  };
  database_cleaner-core = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0v44bn386ipjjh4m2kl53dal8g4d41xajn2jggnmjbhn6965fil6";
      type = "gem";
    };
    version = "2.0.1";
  };
  date = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "149jknsq999gnhy865n33fkk22s0r447k76x9pmcnnwldfv2q7wp";
      type = "gem";
    };
    version = "3.3.4";
  };
  delayed_job = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0s2xg72ljg4cwmr05zi67vcyz8zib46gvvf7rmrdhsyq387m2qcq";
      type = "gem";
    };
    version = "4.1.11";
  };
  delayed_job_active_record = {
    dependencies = ["activerecord" "delayed_job"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b80s5b6dihazdd8kcfrd7z3qv8kijxpxq5027prazdha3pgzadf";
      type = "gem";
    };
    version = "4.1.8";
  };
  devise = {
    dependencies = ["bcrypt" "orm_adapter" "railties" "responders" "warden"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1y57fpcvy1kjd4nb7zk7mvzq62wqcpfynrgblj558k3hbvz4404j";
      type = "gem";
    };
    version = "4.9.4";
  };
  devise_invitable = {
    dependencies = ["actionmailer" "devise"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0blhar8b3rgck4w0pvz9gw60i3h8418fslipyw8i4j63xhjcf9np";
      type = "gem";
    };
    version = "2.0.9";
  };
  diff-lcs = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1znxccz83m4xgpd239nyqxlifdb7m8rlfayk6s259186nkgj6ci7";
      type = "gem";
    };
    version = "1.5.1";
  };
  docile = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lxqxgq71rqwj1lpl9q1mbhhhhhhdkkj7my341f2889pwayk85sz";
      type = "gem";
    };
    version = "1.4.0";
  };
  docx = {
    dependencies = ["nokogiri" "rubyzip"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mwl9w70w7brizggjl01flhmhcsglzadch9j1dg9835v6w962h9v";
      type = "gem";
    };
    version = "0.8.0";
  };
  domain_name = {
    dependencies = ["unf"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lcqjsmixjp52bnlgzh4lg9ppsk52x9hpwdjd53k8jnbah2602h0";
      type = "gem";
    };
    version = "0.5.20190701";
  };
  dotenv = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1n0pi8x8ql5h1mijvm8lgn6bhq4xjb5a500p5r1krq4s6j9lg565";
      type = "gem";
    };
    version = "2.8.1";
  };
  dotenv-rails = {
    dependencies = ["dotenv" "railties"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0v0gcbxzypcvy6fqq4gp80jb310xvdwj5n8qw9ci67g5yjvq2nxh";
      type = "gem";
    };
    version = "2.8.1";
  };
  draper = {
    dependencies = ["actionpack" "activemodel" "activemodel-serializers-xml" "activesupport" "request_store" "ruby2_keywords"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bz1x23lj7zxpijwidbn86c30rzk3fwdpyvbzifaa20qwcgf3qsw";
      type = "gem";
    };
    version = "4.0.2";
  };
  drb = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0h5kbj9hvg5hb3c7l425zpds0vb42phvln2knab8nmazg2zp5m79";
      type = "gem";
    };
    version = "2.2.1";
  };
  email_spec = {
    dependencies = ["htmlentities" "launchy" "mail"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yhn60bmbyv10ikypp5zqrwyg0jfswyvnfqngy18r0dj5p458g7m";
      type = "gem";
    };
    version = "2.2.2";
  };
  erb_lint = {
    dependencies = ["activesupport" "better_html" "parser" "rainbow" "rubocop" "smart_properties"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1h4rpid0d50hikb1yx7apk0vp53qsqgj1cn6rrfqnk580ln4zm5c";
      type = "gem";
    };
    version = "0.5.0";
  };
  erubi = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08s75vs9cxlc4r1q2bjg4br8g9wc5lc5x5vl0vv4zq5ivxsdpgi7";
      type = "gem";
    };
    version = "1.12.0";
  };
  factory_bot = {
    dependencies = ["activesupport"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1glq677vmd3xrdilcx6ar8sdaysm9ldrppg34yzw43jzr6dx47fp";
      type = "gem";
    };
    version = "6.4.5";
  };
  factory_bot_rails = {
    dependencies = ["factory_bot" "railties"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1j6w4rr2cb5wng9yrn2ya9k40q52m0pbz47kzw8xrwqg3jncwwza";
      type = "gem";
    };
    version = "6.4.3";
  };
  faker = {
    dependencies = ["i18n"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gc6li2fcvl9g752sz7nradi46jw7q2kjmmx017b0wfc8v7ayvp3";
      type = "gem";
    };
    version = "3.4.1";
  };
  faraday = {
    dependencies = ["faraday-em_http" "faraday-em_synchrony" "faraday-excon" "faraday-httpclient" "faraday-multipart" "faraday-net_http" "faraday-net_http_persistent" "faraday-patron" "faraday-rack" "faraday-retry" "ruby2_keywords"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1c760q0ks4vj4wmaa7nh1dgvgqiwaw0mjr7v8cymy7i3ffgjxx90";
      type = "gem";
    };
    version = "1.10.3";
  };
  faraday-em_http = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12cnqpbak4vhikrh2cdn94assh3yxza8rq2p9w2j34bqg5q4qgbs";
      type = "gem";
    };
    version = "1.0.0";
  };
  faraday-em_synchrony = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vgrbhkp83sngv6k4mii9f2s9v5lmp693hylfxp2ssfc60fas3a6";
      type = "gem";
    };
    version = "1.0.0";
  };
  faraday-excon = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0h09wkb0k0bhm6dqsd47ac601qiaah8qdzjh8gvxfd376x1chmdh";
      type = "gem";
    };
    version = "1.1.0";
  };
  faraday-httpclient = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fyk0jd3ks7fdn8nv3spnwjpzx2lmxmg2gh4inz3by1zjzqg33sc";
      type = "gem";
    };
    version = "1.0.1";
  };
  faraday-multipart = {
    dependencies = ["multipart-post"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09871c4hd7s5ws1wl4gs7js1k2wlby6v947m2bbzg43pnld044lh";
      type = "gem";
    };
    version = "1.0.4";
  };
  faraday-net_http = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fi8sda5hc54v1w3mqfl5yz09nhx35kglyx72w7b8xxvdr0cwi9j";
      type = "gem";
    };
    version = "1.0.1";
  };
  faraday-net_http_persistent = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0dc36ih95qw3rlccffcb0vgxjhmipsvxhn6cw71l7ffs0f7vq30b";
      type = "gem";
    };
    version = "1.2.0";
  };
  faraday-patron = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19wgsgfq0xkski1g7m96snv39la3zxz6x7nbdgiwhg5v82rxfb6w";
      type = "gem";
    };
    version = "1.0.0";
  };
  faraday-rack = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1h184g4vqql5jv9s9im6igy00jp6mrah2h14py6mpf9bkabfqq7g";
      type = "gem";
    };
    version = "1.0.0";
  };
  faraday-retry = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "153i967yrwnswqgvnnajgwp981k9p50ys1h80yz3q94rygs59ldd";
      type = "gem";
    };
    version = "1.0.3";
  };
  faraday_middleware = {
    dependencies = ["faraday"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bw8mfh4yin2xk7138rg3fhb2p5g2dlmdma88k82psah9mbmvlfy";
      type = "gem";
    };
    version = "1.2.0";
  };
  ffi = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1862ydmclzy1a0cjbvm8dz7847d9rch495ib0zb64y84d3xd4bkg";
      type = "gem";
    };
    version = "1.15.5";
  };
  ffi-compiler = {
    dependencies = ["ffi" "rake"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0c2caqm9wqnbidcb8dj4wd3s902z15qmgxplwyfyqbwa0ydki7q1";
      type = "gem";
    };
    version = "1.0.1";
  };
  filterrific = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0glvw1ksr65s2wh38x5rqfcg04g25ip4as2y6l1pb6mm3b92wkrv";
      type = "gem";
    };
    version = "5.2.5";
  };
  friendly_id = {
    dependencies = ["activerecord"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01v2q0cyqn8za374ygfxzpa5qf4j8yk7ilz6zrv3457wkfwg4670";
      type = "gem";
    };
    version = "5.5.1";
  };
  globalid = {
    dependencies = ["activesupport"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1sbw6b66r7cwdx3jhs46s4lr991969hvigkjpbdl7y3i31qpdgvh";
      type = "gem";
    };
    version = "1.2.1";
  };
  groupdate = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0m7cbahlhd7akkizrn2rjp4g6y6wkg8s3dqas6rgjj1apx2hd535";
      type = "gem";
    };
    version = "6.4.0";
  };
  hashdiff = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nynpl0xbj0nphqx1qlmyggq58ms1phf5i03hk64wcc0a17x1m1c";
      type = "gem";
    };
    version = "1.0.1";
  };
  htmlentities = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nkklqsn8ir8wizzlakncfv42i32wc0w9hxp00hvdlgjr7376nhj";
      type = "gem";
    };
    version = "4.3.4";
  };
  http = {
    dependencies = ["addressable" "http-cookie" "http-form_data" "llhttp-ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bzb8p31kzv6q5p4z5xq88mnqk414rrw0y5rkhpnvpl29x5c3bpw";
      type = "gem";
    };
    version = "5.1.1";
  };
  http-cookie = {
    dependencies = ["domain_name"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13rilvlv8kwbzqfb644qp6hrbsj82cbqmnzcvqip1p6vqx36sxbk";
      type = "gem";
    };
    version = "1.0.5";
  };
  http-form_data = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wx591jdhy84901pklh1n9sgh74gnvq1qyqxwchni1yrc49ynknc";
      type = "gem";
    };
    version = "2.3.0";
  };
  httparty = {
    dependencies = ["csv" "mini_mime" "multi_xml"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0v7s60abgwkahkqi4lf68hmz3j69jli3q25jsf9h1kvijif2lrbq";
      type = "gem";
    };
    version = "0.22.0";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ffix518y7976qih9k1lgnc17i3v6yrlh0a3mckpxdb4wc2vrp16";
      type = "gem";
    };
    version = "1.14.5";
  };
  image_processing = {
    dependencies = ["mini_magick" "ruby-vips"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1f32dzj77p9mfp4q95930vfkp80psf88phjc46jhf9ncl72ykffk";
      type = "gem";
    };
    version = "1.12.2";
  };
  io-console = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08d2lx42pa8jjav0lcjbzfzmw61b8imxr9041pva8xzqabrczp7h";
      type = "gem";
    };
    version = "0.7.2";
  };
  irb = {
    dependencies = ["rdoc" "reline"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14pji5w708d6v63m3yvyfx1d9gg0mi5x1a2czxf6259zncq2ymda";
      type = "gem";
    };
    version = "1.13.1";
  };
  jbuilder = {
    dependencies = ["actionview" "activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1li6hwkcz1z7g6wvhvw160bb1jkzm2i928gspfmir45q80rbxsa7";
      type = "gem";
    };
    version = "2.12.0";
  };
  jsbundling-rails = {
    dependencies = ["railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bfh1mwkpq53bd3k0nsnqwmsc76hrygfgngqd5hl7sy06wmp2h11";
      type = "gem";
    };
    version = "1.3.0";
  };
  json = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0b4qsi8gay7ncmigr0pnbxyb17y3h8kavdyhsh7nrlqwr35vb60q";
      type = "gem";
    };
    version = "2.7.2";
  };
  json-schema = {
    dependencies = ["addressable"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j9dz9sf7swwmfahlngph8n9ibm0cx7mdy9zpv3w44578nbkka49";
      type = "gem";
    };
    version = "4.1.1";
  };
  jwt = {
    dependencies = ["base64"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02m3vza49pb9dirwpn8vmzbcypi3fc6l3a9dh253jwm1121g7ajb";
      type = "gem";
    };
    version = "2.8.1";
  };
  language_server-protocol = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gvb1j8xsqxms9mww01rmdl78zkd72zgxaap56bhv8j45z05hp1x";
      type = "gem";
    };
    version = "3.17.0.3";
  };
  launchy = {
    dependencies = ["addressable"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06r43899384das2bkbrpsdxsafyyqa94il7111053idfalb4984a";
      type = "gem";
    };
    version = "2.5.2";
  };
  letter_opener = {
    dependencies = ["launchy"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cnv3ggnzyagl50vzs1693aacv08bhwlprcvjp8jcg2w7cp3zwrg";
      type = "gem";
    };
    version = "1.10.0";
  };
  lint_roller = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11yc0d84hsnlvx8cpk4cbj6a4dz9pk0r1k29p0n1fz9acddq831c";
      type = "gem";
    };
    version = "1.1.0";
  };
  llhttp-ffi = {
    dependencies = ["ffi-compiler" "rake"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00dh6zmqdj59rhcya0l4b9aaxq6n8xizfbil93k0g06gndyk5xz5";
      type = "gem";
    };
    version = "0.4.0";
  };
  lograge = {
    dependencies = ["actionpack" "activesupport" "railties" "request_store"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qcsvh9k4c0cp6agqm9a8m4x2gg7vifryqr7yxkg2x9ph9silds2";
      type = "gem";
    };
    version = "0.14.0";
  };
  loofah = {
    dependencies = ["crass" "nokogiri"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zkjqf37v2d7s11176cb35cl83wls5gm3adnfkn2zcc61h3nxmqh";
      type = "gem";
    };
    version = "2.22.0";
  };
  mail = {
    dependencies = ["mini_mime" "net-imap" "net-pop" "net-smtp"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bf9pysw1jfgynv692hhaycfxa8ckay1gjw5hz3madrbrynryfzc";
      type = "gem";
    };
    version = "2.8.1";
  };
  marcel = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "190n2mk8m1l708kr88fh6mip9sdsh339d2s6sgrik3sbnvz4jmhd";
      type = "gem";
    };
    version = "1.0.4";
  };
  matrix = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1h2cgkpzkh3dd0flnnwfq6f3nl2b1zff9lvqz8xs853ssv5kq23i";
      type = "gem";
    };
    version = "0.4.2";
  };
  method_source = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pnyh44qycnf9mzi1j6fywd5fkskv3x7nmsqrrws0rjn5dd4ayfp";
      type = "gem";
    };
    version = "1.0.0";
  };
  mini_magick = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1aj604x11d9pksbljh0l38f70b558rhdgji1s9i763hiagvvx2hs";
      type = "gem";
    };
    version = "4.11.0";
  };
  mini_mime = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vycif7pjzkr29mfk4dlqv3disc5dn0va04lkwajlpr1wkibg0c6";
      type = "gem";
    };
    version = "1.1.5";
  };
  mini_portile2 = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "149r94xi6b3jbp6bv72f8383b95ndn0p5sxnq11gs1j9jadv0ajf";
      type = "gem";
    };
    version = "2.8.6";
  };
  minitest = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "181rfs9drd34b3akbfbfg0ynz07v74pfkzbb977bxa50nrlqwj2c";
      type = "gem";
    };
    version = "5.23.0";
  };
  multi_xml = {
    dependencies = ["bigdecimal"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06x61ca5j84nyhr1mwh9r436yiphnc5hmacb3gwqyn5gd0611kjg";
      type = "gem";
    };
    version = "0.7.1";
  };
  multipart-post = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1033p35166d9p97y4vajbbvr13pmkk9zwn7sylxpmk9jrpk8ri67";
      type = "gem";
    };
    version = "2.4.0";
  };
  mutex_m = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ma093ayps1m92q845hmpk0dmadicvifkbf05rpq9pifhin0rvxn";
      type = "gem";
    };
    version = "0.2.0";
  };
  net-http-persistent = {
    dependencies = ["connection_pool"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yfypmfg1maf20yfd22zzng8k955iylz7iip0mgc9lazw36g8li7";
      type = "gem";
    };
    version = "4.0.1";
  };
  net-imap = {
    dependencies = ["date" "net-protocol"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18yclv06n0cy8jqmi11sd1dl8nasc5n5r1mhan2v51j7jd3z58v3";
      type = "gem";
    };
    version = "0.4.12";
  };
  net-pop = {
    dependencies = ["net-protocol"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wyz41jd4zpjn0v1xsf9j778qx1vfrl24yc20cpmph8k42c4x2w4";
      type = "gem";
    };
    version = "0.1.2";
  };
  net-protocol = {
    dependencies = ["timeout"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a32l4x73hz200cm587bc29q8q9az278syw3x6fkc9d1lv5y0wxa";
      type = "gem";
    };
    version = "0.2.2";
  };
  net-smtp = {
    dependencies = ["net-protocol"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0amlhz8fhnjfmsiqcjajip57ici2xhw089x7zqyhpk51drg43h2z";
      type = "gem";
    };
    version = "0.5.0";
  };
  nio4r = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "017nbw87dpr4wyk81cgj8kxkxqgsgblrkxnmmadc77cg9gflrfal";
      type = "gem";
    };
    version = "2.7.3";
  };
  nokogiri = {
    dependencies = ["mini_portile2" "racc"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lla2macphrlbzkirk0nwwwhcijrfymyfjjw1als0kwqd0n1cdpc";
      type = "gem";
    };
    version = "1.16.5";
  };
  noticed = {
    dependencies = ["http" "rails"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0v77w7yjam34hfwjpkmlbx8njvz5wicpn91q9fczwcqa95zsqqg0";
      type = "gem";
    };
    version = "1.6.3";
  };
  oj = {
    dependencies = ["bigdecimal"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0g5nx99lrwmk6ynfaacqkyijnhvi4mckm77bmvpa0jmfg068l26h";
      type = "gem";
    };
    version = "3.16.3";
  };
  orm_adapter = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fg9jpjlzf5y49qs9mlpdrgs5rpcyihq1s4k79nv9js0spjhnpda";
      type = "gem";
    };
    version = "0.5.0";
  };
  parallel = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15wkxrg1sj3n1h2g8jcrn7gcapwcgxr659ypjf75z1ipkgxqxwsv";
      type = "gem";
    };
    version = "1.24.0";
  };
  parallel_tests = {
    dependencies = ["parallel"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0q5q38sfrpwgcqwf5sl6xals5w11xayh8i9nq1vxya2sbrzrgbcq";
      type = "gem";
    };
    version = "4.7.1";
  };
  paranoia = {
    dependencies = ["activerecord"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18d3x7d1k804d4pm5lxgnkwi5farbxhk8ndvsh8j6i03lrl6hqp7";
      type = "gem";
    };
    version = "2.6.3";
  };
  parser = {
    dependencies = ["ast" "racc"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0i0255l4pw6c1bc0ny98wx5qck25irinq062ijg4002mj8mydwvq";
      type = "gem";
    };
    version = "3.3.1.0";
  };
  pdf-forms = {
    dependencies = ["cliver" "rexml" "safe_shell"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fha4fs2hdapixm5d1613ds0vlfs07bipskm6ihrkfh7lx6dw00p";
      type = "gem";
    };
    version = "1.5.0";
  };
  pg = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "071b55bhsz7mivlnp2kv0a11msnl7xg5awvk8mlflpl270javhsb";
      type = "gem";
    };
    version = "1.5.6";
  };
  pretender = {
    dependencies = ["actionpack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xxdizzp7l0cbccmh499rifr6q0khjgfqv0kir39haqwphjhy4h2";
      type = "gem";
    };
    version = "0.5.0";
  };
  pry = {
    dependencies = ["coderay" "method_source"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0k9kqkd9nps1w1r1rb7wjr31hqzkka2bhi8b518x78dcxppm9zn4";
      type = "gem";
    };
    version = "0.14.2";
  };
  pry-byebug = {
    dependencies = ["byebug" "pry"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1y41al94ks07166qbp2200yzyr5y60hm7xaiw4lxpgsm4b1pbyf8";
      type = "gem";
    };
    version = "3.10.1";
  };
  psych = {
    dependencies = ["stringio"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0s5383m6004q76xm3lb732bp4sjzb6mxb6rbgn129gy2izsj4wrk";
      type = "gem";
    };
    version = "5.1.2";
  };
  public_suffix = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14y4vzjwf5gp0mqgs880kis0k7n2biq8i6ci6q2n315kichl1hvj";
      type = "gem";
    };
    version = "5.0.5";
  };
  puma = {
    dependencies = ["nio4r"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0i2vaww6qcazj0ywva1plmjnj6rk23b01szswc5jhcq7s2cikd1y";
      type = "gem";
    };
    version = "6.4.2";
  };
  pundit = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18vz32n5ca5j5h971axnnfa8rjrfqnqv0zkgjv8xmbpb05c9m83w";
      type = "gem";
    };
    version = "2.3.2";
  };
  racc = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "021s7maw0c4d9a6s07vbmllrzqsj2sgmrwimlh8ffkvwqdjrld09";
      type = "gem";
    };
    version = "1.8.0";
  };
  rack = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hj0rkw2z9r1lcg2wlrcld2n3phwrcgqcp7qd1g9a7hwgalh2qzx";
      type = "gem";
    };
    version = "2.2.9";
  };
  rack-attack = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0z6pj5vjgl6swq7a33gssf795k958mss8gpmdb4v4cydcs7px91w";
      type = "gem";
    };
    version = "6.7.0";
  };
  rack-cors = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02lvkg1nb4z3zc2nry545dap7a64bb9h2k8waxfz0jkabkgnpimw";
      type = "gem";
    };
    version = "2.0.1";
  };
  rack-session = {
    dependencies = ["rack"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xhxhlsz6shh8nm44jsmd9276zcnyzii364vhcvf0k8b8bjia8d0";
      type = "gem";
    };
    version = "1.0.2";
  };
  rack-test = {
    dependencies = ["rack"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ysx29gk9k14a14zsp5a8czys140wacvp91fja8xcja0j1hzqq8c";
      type = "gem";
    };
    version = "2.1.0";
  };
  rackup = {
    dependencies = ["rack" "webrick"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wbr03334ba9ilcq25wh9913xciwj0j117zs60vsqm0zgwdkwpp9";
      type = "gem";
    };
    version = "1.0.0";
  };
  rails = {
    dependencies = ["actioncable" "actionmailbox" "actionmailer" "actionpack" "actiontext" "actionview" "activejob" "activemodel" "activerecord" "activestorage" "activesupport" "railties"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pl2jgnbm9p031jvbihpbnpwn005107xb1794ps0ayairb6qhldn";
      type = "gem";
    };
    version = "7.1.3.3";
  };
  rails-controller-testing = {
    dependencies = ["actionpack" "actionview" "activesupport"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "151f303jcvs8s149mhx2g5mn67487x0blrf9dzl76q1nb7dlh53l";
      type = "gem";
    };
    version = "1.0.5";
  };
  rails-dom-testing = {
    dependencies = ["activesupport" "minitest" "nokogiri"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fx9dx1ag0s1lr6lfr34lbx5i1bvn3bhyf3w3mx6h7yz90p725g5";
      type = "gem";
    };
    version = "2.2.0";
  };
  rails-html-sanitizer = {
    dependencies = ["loofah" "nokogiri"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pm4z853nyz1bhhqr7fzl44alnx4bjachcr6rh6qjj375sfz3sc6";
      type = "gem";
    };
    version = "1.6.0";
  };
  railties = {
    dependencies = ["actionpack" "activesupport" "irb" "rackup" "rake" "thor" "zeitwerk"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02xic4iyvqxj4hs5xzywg4zrff8s77c7xb1jchjfmdrzclnz51zx";
      type = "gem";
    };
    version = "7.1.3.3";
  };
  rainbow = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
      type = "gem";
    };
    version = "3.1.1";
  };
  rake = {
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17850wcwkgi30p7yqh60960ypn7yibacjjha0av78zaxwvd3ijs6";
      type = "gem";
    };
    version = "13.2.1";
  };
  rdoc = {
    dependencies = ["psych"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ib3cnf4yllvw070gr4bz94sbmqx3haqc5f846fsvdcs494vgxrr";
      type = "gem";
    };
    version = "6.6.3.1";
  };
  regexp_parser = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ik40vcv7mqigsfpqpca36hpmnx0536xa825ai5qlkv3mmkyf9ss";
      type = "gem";
    };
    version = "2.9.2";
  };
  reline = {
    dependencies = ["io-console"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06rlp3wjcbwbgw3xlawclzzmj6ryn6ap65nh54x5yzgx0c3jlqqz";
      type = "gem";
    };
    version = "0.5.7";
  };
  request_store = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jw89j9s5p5cq2k7ffj5p4av4j4fxwvwjs1a4i9g85d38r9mvdz1";
      type = "gem";
    };
    version = "1.7.0";
  };
  responders = {
    dependencies = ["actionpack" "railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06ilkbbwvc8d0vppf8ywn1f79ypyymlb9krrhqv4g0q215zaiwlj";
      type = "gem";
    };
    version = "3.1.1";
  };
  rexml = {
    dependencies = ["strscan"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0d8ivcirrrxpkpjc1c835wknc9s2fl54xpw08s177yfrh5ish209";
      type = "gem";
    };
    version = "3.2.8";
  };
  rspec-core = {
    dependencies = ["rspec-support"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0k252n7s80bvjvpskgfm285a3djjjqyjcarlh3aq7a4dx2s94xsm";
      type = "gem";
    };
    version = "3.13.0";
  };
  rspec-expectations = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bhhjzwdk96vf3gq3rs7mln80q27fhq82hda3r15byb24b34h7b2";
      type = "gem";
    };
    version = "3.13.0";
  };
  rspec-mocks = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f3vgp43hajw716vmgjv6f4ar6f97zf50snny6y3fy9kkj4qjw88";
      type = "gem";
    };
    version = "3.13.1";
  };
  rspec-rails = {
    dependencies = ["actionpack" "activesupport" "railties" "rspec-core" "rspec-expectations" "rspec-mocks" "rspec-support"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02wr7fl189p1lnpaylz48dlp1n5y763w92gk59s0345hwfr4m1q2";
      type = "gem";
    };
    version = "6.1.2";
  };
  rspec-support = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03z7gpqz5xkw9rf53835pa8a9vgj4lic54rnix9vfwmp2m7pv1s8";
      type = "gem";
    };
    version = "3.13.1";
  };
  rspec_junit_formatter = {
    dependencies = ["rspec-core"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "059bnq1gcwl9g93cqf13zpz38zk7jxaa43anzz06qkmfwrsfdpa0";
      type = "gem";
    };
    version = "0.6.0";
  };
  rswag-api = {
    dependencies = ["activesupport" "railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0prlhpiqvs6lvnmlvc9mjbfh7411z8zhc61cn0fnxx1iwp38fsin";
      type = "gem";
    };
    version = "2.13.0";
  };
  rswag-specs = {
    dependencies = ["activesupport" "json-schema" "railties" "rspec-core"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1iyqd95l8r8m6jna451xb20lsp0jiajk1gbw845qlyqf6d69xyx2";
      type = "gem";
    };
    version = "2.13.0";
  };
  rswag-ui = {
    dependencies = ["actionpack" "railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bsc1wirnql1h0xxmi6afa8gpwqi5j778qc1l4kx8x3lsgghfi0m";
      type = "gem";
    };
    version = "2.13.0";
  };
  rubocop = {
    dependencies = ["json" "language_server-protocol" "parallel" "parser" "rainbow" "regexp_parser" "rexml" "rubocop-ast" "ruby-progressbar" "unicode-display_width"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zkdxkhvhmxap5w2rncpmrq40dw0pbz81sa1ivsr7kh0p8j0a9x3";
      type = "gem";
    };
    version = "1.63.5";
  };
  rubocop-ast = {
    dependencies = ["parser"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "063qgvqbyv354icl2sgx758z22wzq38hd9skc3n96sbpv0cdc1qv";
      type = "gem";
    };
    version = "1.31.3";
  };
  rubocop-performance = {
    dependencies = ["rubocop" "rubocop-ast"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16jayzjaaglhx69s6b83acpdzcxxccfkcn69gfpkimf2j64zlm7c";
      type = "gem";
    };
    version = "1.21.0";
  };
  ruby-progressbar = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cwvyb7j47m7wihpfaq7rc47zwwx9k4v7iqd9s1xch5nm53rrz40";
      type = "gem";
    };
    version = "1.13.0";
  };
  ruby-vips = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19pzpx406rr9s3qk527rn9y3b76sjq5pi7y0xzqiy50q3k0hhg7g";
      type = "gem";
    };
    version = "2.1.4";
  };
  ruby2_keywords = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vz322p8n39hz3b4a9gkmz9y7a5jaz41zrm2ywf31dvkqm03glgz";
      type = "gem";
    };
    version = "0.0.5";
  };
  rubyzip = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0grps9197qyxakbpw02pda59v45lfgbgiyw48i0mq9f2bn9y6mrz";
      type = "gem";
    };
    version = "2.3.2";
  };
  sablon = {
    dependencies = ["nokogiri" "rubyzip"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "010r39zasaabd1kr34qbdhir2ialbg1p68rziinxz6iwckvgbzn9";
      type = "gem";
    };
    version = "0.3.2";
  };
  safe_shell = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02hvmik4amhcwpnzbnxs61gyq6p6vjpgn2d4pm8gh96rqxjkw7g4";
      type = "gem";
    };
    version = "1.1.0";
  };
  scout_apm = {
    dependencies = ["parser"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wyih4c8fyb83cp21b1igbrf8nvj0q8ivgkmd1zwgcywmbvmw9lj";
      type = "gem";
    };
    version = "5.3.8";
  };
  selenium-webdriver = {
    dependencies = ["base64" "rexml" "rubyzip" "websocket"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qrjr30qs01b27km6ipzc2zasdlzhdgri5q7qrb53z1j8l0n82y3";
      type = "gem";
    };
    version = "4.21.1";
  };
  shoulda-matchers = {
    dependencies = ["activesupport"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pfq0w167v4055k0km64sxik1qslhsi32wl2jlidmfzkqmcw00m7";
      type = "gem";
    };
    version = "6.2.0";
  };
  simplecov = {
    dependencies = ["docile" "simplecov-html" "simplecov_json_formatter"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "198kcbrjxhhzca19yrdcd6jjj9sb51aaic3b0sc3pwjghg3j49py";
      type = "gem";
    };
    version = "0.22.0";
  };
  simplecov-html = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yx01bxa8pbf9ip4hagqkp5m0mqfnwnw2xk8kjraiywz4lrss6jb";
      type = "gem";
    };
    version = "0.12.3";
  };
  simplecov_json_formatter = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0a5l0733hj7sk51j81ykfmlk2vd5vaijlq9d5fn165yyx3xii52j";
      type = "gem";
    };
    version = "0.1.4";
  };
  smart_properties = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jrqssk9qhwrpq41arm712226vpcr458xv6xaqbk8cp94a0kycpr";
      type = "gem";
    };
    version = "1.17.0";
  };
  spring = {
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bm5w3mp597vy0cjwx609k3jdh5zik36ffmna7hchrn9g96s45w5";
      type = "gem";
    };
    version = "4.2.1";
  };
  spring-commands-rspec = {
    dependencies = ["spring"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0b0svpq3md1pjz5drpa5pxwg8nk48wrshq8lckim4x3nli7ya0k2";
      type = "gem";
    };
    version = "1.0.4";
  };
  sprockets = {
    dependencies = ["concurrent-ruby" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qj82dcfkk6c4zw357k5r05s5iwvyddh57bpwj0a1hjgaw70pcb8";
      type = "gem";
    };
    version = "4.1.1";
  };
  sprockets-rails = {
    dependencies = ["actionpack" "activesupport" "sprockets"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b9i14qb27zs56hlcc2hf139l0ghbqnjpmfi0054dxycaxvk5min";
      type = "gem";
    };
    version = "3.4.2";
  };
  standard = {
    dependencies = ["language_server-protocol" "lint_roller" "rubocop" "standard-custom" "standard-performance"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1135p2imjcx1a9qd1pj4kw09g6ly151kscc6n08iw0zfdxy09vmp";
      type = "gem";
    };
    version = "1.36.0";
  };
  standard-custom = {
    dependencies = ["lint_roller" "rubocop"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0av55ai0nv23z5mhrwj1clmxpgyngk7vk6rh58d4y1ws2y2dqjj2";
      type = "gem";
    };
    version = "1.0.2";
  };
  standard-performance = {
    dependencies = ["lint_roller" "rubocop-performance"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1551dwjwyqy7rckjgcb25k51k6wndn8m37mmbpanr0k4b6v757yy";
      type = "gem";
    };
    version = "1.4.0";
  };
  stimulus-rails = {
    dependencies = ["railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0b2nbj25cqhhklj04bfk0q3532skm4qcak6xki65yq2fssqrl7sd";
      type = "gem";
    };
    version = "1.3.3";
  };
  stringio = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "063psvsn1aq6digpznxfranhcpmi0sdv2jhra5g0459sw0x2dxn1";
      type = "gem";
    };
    version = "3.1.0";
  };
  strong_migrations = {
    dependencies = ["activerecord"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0p9g8jqcakpwmbs6f77ydmbiwbgx9c5nr6jgwxh4xx6xpig1bphq";
      type = "gem";
    };
    version = "1.8.0";
  };
  strscan = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mamrl7pxacbc79ny5hzmakc9grbjysm3yy6119ppgsg44fsif01";
      type = "gem";
    };
    version = "3.1.0";
  };
  thor = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vq1fjp45az9hfp6fxljhdrkv75cvbab1jfrwcw738pnsiqk8zps";
      type = "gem";
    };
    version = "1.3.1";
  };
  timeout = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16mvvsmx90023wrhf8dxc1lpqh0m8alk65shb7xcya6a9gflw7vg";
      type = "gem";
    };
    version = "0.4.1";
  };
  traceroute = {
    dependencies = ["rails"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1s06m08jqzv0idk39xknqmnacg684y48cinszc89bvg73i9knjjq";
      type = "gem";
    };
    version = "0.8.1";
  };
  twilio-ruby = {
    dependencies = ["faraday" "jwt" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19qr60lmycbnfb55drnhszmbs991y2ijxx1jav82cyvmzl53s883";
      type = "gem";
    };
    version = "7.0.2";
  };
  tzinfo = {
    dependencies = ["concurrent-ruby"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16w2g84dzaf3z13gxyzlzbf748kylk5bdgg3n1ipvkvvqy685bwd";
      type = "gem";
    };
    version = "2.0.6";
  };
  unf = {
    dependencies = ["unf_ext"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bh2cf73i2ffh4fcpdn9ir4mhq8zi50ik0zqa1braahzadx536a9";
      type = "gem";
    };
    version = "0.1.4";
  };
  unf_ext = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yj2nz2l101vr1x9w2k83a0fag1xgnmjwp8w8rw4ik2rwcz65fch";
      type = "gem";
    };
    version = "0.0.8.2";
  };
  unicode-display_width = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1d0azx233nags5jx3fqyr23qa2rhgzbhv8pxp46dgbg1mpf82xky";
      type = "gem";
    };
    version = "2.5.0";
  };
  uniform_notifier = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dfvqixshwvm82b9qwdidvnkavdj7s0fbdbmyd4knkl6l3j9xcwr";
      type = "gem";
    };
    version = "1.16.0";
  };
  view_component = {
    dependencies = ["activesupport" "concurrent-ruby" "method_source"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1px8bcmj43xzcnzs7a8sh2qvhr07afbk0b2qjdjns4zjprsqksml";
      type = "gem";
    };
    version = "3.9.0";
  };
  warden = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1l7gl7vms023w4clg02pm4ky9j12la2vzsixi2xrv9imbn44ys26";
      type = "gem";
    };
    version = "1.2.9";
  };
  web-console = {
    dependencies = ["actionview" "activemodel" "bindex" "railties"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "087y4byl2s3fg0nfhix4s0r25cv1wk7d2j8n5324waza21xg7g77";
      type = "gem";
    };
    version = "4.2.1";
  };
  webmock = {
    dependencies = ["addressable" "crack" "hashdiff"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07zk8ljq5kyd1mm9qw3452fcnf7frg3irh9ql8ln2m8zbi1qf1qh";
      type = "gem";
    };
    version = "3.23.0";
  };
  webrick = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13qm7s0gr2pmfcl7dxrmq38asaza4w0i2n9my4yzs499j731wh8r";
      type = "gem";
    };
    version = "1.8.1";
  };
  websocket = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a4zc8d0d91c3xqwapda3j3zgpfwdbj76hkb69xn6qvfkfks9h9c";
      type = "gem";
    };
    version = "1.2.10";
  };
  websocket-driver = {
    dependencies = ["websocket-extensions"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nyh873w4lvahcl8kzbjfca26656d5c6z3md4sbqg5y1gfz0157n";
      type = "gem";
    };
    version = "0.7.6";
  };
  websocket-extensions = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hc2g9qps8lmhibl5baa91b4qx8wqw872rgwagml78ydj8qacsqw";
      type = "gem";
    };
    version = "0.1.5";
  };
  wicked = {
    dependencies = ["railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07ck2z3dkgc2yp4w20dav77w754r55wdz2gm7agnslmqn1n2bbvw";
      type = "gem";
    };
    version = "2.0.0";
  };
  xpath = {
    dependencies = ["nokogiri"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bh8lk9hvlpn7vmi6h4hkcwjzvs2y0cmkk3yjjdr8fxvj6fsgzbd";
      type = "gem";
    };
    version = "3.2.0";
  };
  zeitwerk = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ayraiqfhhjzpyr4yxp035002lq78ip1zhr0ix87rn3rqpnsrn3h";
      type = "gem";
    };
    version = "2.6.14";
  };
}
