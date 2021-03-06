# make a shortcut from home directory to our group folder 
# file.symlink(from = '/nfs/HealthandResourcePolicy-data', to = 'data')

setwd("~/healthandresourcepolicy/data/Task 1/corpus/documents_190912_selected")

# clear workspace
rm (list =ls())
cat("\014")
# -----------------------------------------------------
# trying to make a document corpus (corpus is a set of documents, 
# document is each a unit in the corpus)
# refs: 
# https://tutorials.quanteda.io/import-data/multiple-files/
# Welbers et al. 2017 

# install.packages("readtext")
library(readtext)
# install.packages("quanteda")
library(quanteda)

# test based on Welbers p. 248 
filepath <- ("/nfs/HealthandResourcePolicy-data/Task 1/corpus/documents_190912_selected")
# testing with a subset from 1980s
# approach from quanteda github 
# ref: https://github.com/quanteda/quanteda_tutorials/blob/master/content/import-data/multiple-files.en.Rmarkdown

# test based on https://tutorials.quanteda.io/import-data/multiple-files/
# information to include in file name: number_org_lang_year_doctype

# test for pdfs 
#test_data <- readtext(paste0(filepath, "/*.pdf"), 
  # docvarsfrom = "filenames", 
  # docvarnames = c("document", "language"),
  # sep = "_") # pdf works for better quality pdfs

# test for word docs 
#test_data <- readtext(paste0(filepath, "/*.docx"), 
  # docvarsfrom = "filenames", 
  # docvarnames = c("document", "language"),
  # sep = "_") 

# test for text documents (this one seems to work the best for our files)
test_data <- readtext(paste0(filepath, "/*.txt"), 
                      docvarsfrom = "filenames", 
                      docvarnames = c("doc_number", "organization", "language","year", "doc_type" ),
                      dvsep = "_") 
str(test_data)
names(test_data) 
encoding(test_data) 

# create new variable for decade
for (i in seq(1960,2010,10)){
 test_data$decade[test_data$year >= i & test_data$year <= i+9] = i
}
test_data$decade<-paste(test_data$decade,"s",sep="")

names(test_data) # check it worked
table(test_data$year)
table(test_data$decade)
table(test_data$doc_type)
sum <- table(test_data$decade, test_data$doc_type)
#table(test_data$decade, test_data$organization) 
write.table(sum, "decade_by_type.txt", sep="\t")

# form a corpus 
# ref: https://tutorials.quanteda.io/basic-operations/corpus/corpus/
test_corpus <- corpus(test_data)
summary(test_corpus) 
# -----------------------------------------------------
# keep corpus as an original reference copy -- do not edit directly 
# make timeline based on quanteda quickstart code 
tokenInfo <- summary(test_corpus)
if (require(ggplot2))
ggplot(data = tokenInfo, aes(x = year, y = Tokens, group = 1, na.rm = TRUE)) + geom_line() + geom_point() +
  scale_x_continuous(labels = c(seq(1789, 2017, 12)), breaks = seq(1789, 2017, 12)) +
  theme_bw()

write.table(tokenInfo, "tokens.txt", sep="\t")
# -----------------------------------------------------
# explore documents
kwic(test_corpus, "santé") # shows "keywords-in-context"
# -----------------------------------------------------
# build out stopwords 
# ref: http://docs.quanteda.io/reference/stopwords.html 
head(stopwords("french")) # built in stopwords 

# manually removing stop words
# ref: https://github.com/quanteda/quanteda/issues/937
# stopwords and dropwords for unigrams (dropwords = our term for words that should be dropped in addition to stop words)
stopwords1<-c("a", "plus", "i", "mise", "o", "the", "d'un", "d'une", "entre", "dont","of", 
                "b", "ainsi", "comme", "si", "non", "and", "e", "afin", "á", "r", "x", "tous", 
                "f", "ii", "an", "peu", "donc", "page","p", "in", "rév", "lors","etc", "i i i", "o o", 
                "x x", " d'une", "ha", "cas")
dropwords1 <-c("fleuve", "sénégal","senegal", "coyne", "et bellier", "fcfa", "être", "rapport", "agrer", 
               "mio")

# stopwords and dropwords for bigrams and trigrams
stopwords2<-c("a", "plus", "i", "mise", "o", "the", "d’un", "d'une", "entre", "dont","of", 
              "b", "ainsi", "comme", "si", "non", "and", "e", "afin", "á", "r", "x", "tous", 
              "f", "ii", "an", "peu", "donc", "page","p", "in", "rév", "lors","etc", "i i i", "o o", "x x",
              "i_i", "o_o")
dropwords2 <-c("fleuve", "sénégal","senegal", "coyne", "et bellier", "fcfa", "f_cfa", "of_the", "doit_être", 
               "doivent_être", "b.doc_rp", "gouina_b.doc", "bellier_gouina", "rp_bellier", "s.a_n.v", "phase_gouina",
               "n.v_mali", "mali_etude", "mio_nombre", "st_louis", "d'autre_part")

stopwords3<-c("a", "plus", "i", "mise", "o", "the", "d’un", "d'une", "entre", "dont","of", 
              "b", "ainsi", "comme", "si", "non", "and", "e", "afin", "á", "r", "x", "tous", 
              "f", "ii", "an", "peu", "donc", "page","p", "in", "rév", "lors","etc", "i i i", "o o", "x x",
              "i_i_i", "o_o_o", "i_i_i_i_i_i")
dropwords3 <-c("fleuve", "sénégal","senegal", "coyne", "et bellier", "fcfa", "s.a_agrer_n.v", "rapport_final_phase", "b.doc_rapport_", "rapport_rp_bellier", 
                " n.v_mali_etude", "s.a_n.v_mali", "mio_nombre_d'unités", "n.v_mali_etude", "b.doc_rp_bellier", 
               "phase_gouina_b.doc", "rp_bellier_gouina", "mali_etude_impacts", "gouina_b.doc_rp")
# -----------------------------------------------------
# corpus --> tokens 
test_tokens <- tokens(test_corpus, remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = FALSE, ngrams = 1)

# create corpi? with bigrams and trigrams
tokens_n2 <- tokens_remove(test_tokens, c(stopwords("french"), stopwords1, dropwords1))
tokens_n2 <- tokens(tokens_n2, remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = FALSE, ngrams = 2)
tokens_n2 <- tokens_remove(tokens_n2, c(stopwords("french"), stopwords2, dropwords2))

tokens_n3 <- tokens_remove(test_tokens, c(stopwords("french"), stopwords1, dropwords1))
tokens_n3 <- tokens(tokens_n3, remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = FALSE, ngrams = 3)
tokens_n3 <- tokens_remove(tokens_n3, c(stopwords("french"), stopwords3, dropwords3))

# -----------------------------------------------------
# tokens --> dfm 
# note: if we want a to use bi or trigrams in our analysis we set that when we tokenize and then make than into a dfm 
test_dfm <- dfm(test_tokens, tolower = TRUE, remove = c(stopwords("french"), stopwords1, dropwords1), remove_punct = TRUE)
topfeatures(test_dfm) # picking up errors: i_i_i etc., removed using stopwords1 above -- errors seem to depend a lot on n-gram determination

# dfm for bigrams
dfm_n2 <- dfm(tokens_n2, tolower = TRUE, remove = c(stopwords("french"), stopwords2, dropwords2), remove_punct = TRUE)
topfeatures(dfm_n2)

#dfm for trigrams
dfm_n3 <- dfm(tokens_n3, tolower = TRUE, remove_punct = TRUE)
topfeatures(dfm_n3)

# -----------------------------------------------------
# frequency analysis
freq <- textstat_frequency(test_dfm) # biggest issue seems to be e with accent (fixed using correct encoding)
head(freq, 50)

write.table(freq, "freq_n1.txt", sep="\t")

freq_n2 <- textstat_frequency(dfm_n2)
head(freq_n2, 200)

write.table(freq_n2, "freq_n2.txt", sep="\t")

freq_n3 <- textstat_frequency(dfm_n3)
head(freq_n3, 200)

write.table(freq_n3, "freq_n3.txt", sep="\t")

dfm_select(test_dfm, pattern = "é", valuetype = "regex") %>% topfeatures()

nfeat(test_dfm) # number of features

# -----------------------------------------------------
# make a feature co-occurence matrix https://tutorials.quanteda.io/basic-operations/fcm/fcm/
test_dfm_trim <- dfm_trim(test_dfm, min_termfreq = 100)
nfeat(test_dfm_trim) # number of features
test_fcm <- fcm(test_dfm_trim) # r keeps failing when I try to do this, works if you limit term freq
topfeatures(test_fcm)

feat <- names(topfeatures(test_fcm, 50))
test_fcm_trim_select <- fcm_select(test_fcm, pattern = feat)
dim(test_fcm_trim_select)

size <- log(colSums(dfm_select(test_dfm, feat)))
set.seed(144)
textplot_network(test_fcm_trim_select, min_freq = 0.8, vertex_size = size / max(size) * 3)

# fcm with bigrams
dfm_n2_trim <- dfm_trim(dfm_n2, min_termfreq = 100)
nfeat(dfm_n2_trim) # number of features
fcm_n2 <- fcm(dfm_n2_trim) # r keeps failing when I try to do this, works if you limit term freq
topfeatures(fcm_n2)

feat <- names(topfeatures(fcm_n2, 50))
fcm_n2_trim_select <- fcm_select(fcm_n2, pattern = feat)
dim(fcm_n2_trim_select)

size <- log(colSums(dfm_select(dfm_n2, feat)))
set.seed(144)
textplot_network(fcm_n2_trim_select, min_freq = 0.8, vertex_size = size / max(size) * 3) 
# this is helpful to identify outliers 

#fcm with trigrams 
dfm_n3_trim <- dfm_trim(dfm_n3, min_termfreq = 100)
nfeat(dfm_n3_trim) # number of features
fcm_n3 <- fcm(dfm_n3_trim) # r keeps failing when I try to do this, works if you limit term freq
topfeatures(fcm_n3)

feat <- names(topfeatures(fcm_n3, 50))
fcm_n3_trim_select <- fcm_select(fcm_n3, pattern = feat)
dim(fcm_n3_trim_select)

size <- log(colSums(dfm_select(dfm_n3, feat)))
set.seed(144)
textplot_network(fcm_n3_trim_select, min_freq = 0.8, vertex_size = size / max(size) * 3) 

# -----------------------------------------------------
# descriptive statistics (unigram)
freq <- textstat_frequency(test_dfm, n = 5, groups = "doc_type") # what are the groups assessmentX and studyX? (TA) 
# just marking the ones that I could recall that are incomplete pdfs
head(freq, 20)

freq_by_year <- textstat_frequency(test_dfm, n=5, groups = "year")
head(freq_by_year, 20)
freq_by_decade <- textstat_frequency(test_dfm, n=5, groups = "decade") 
head(freq_by_decade, 20)

# bigram
freq_by_year_n2 <- textstat_frequency(dfm_n2, n=5, groups = "year")
head(freq_by_year_n2, 20)
freq_by_decade_n2 <- textstat_frequency(dfm_n2, n=5, groups = "decade") 
head(freq_by_decade_n2, 20)

# trigram
freq_by_year_n3 <- textstat_frequency(dfm_n3, n=5, groups = "year")
head(freq_by_year_n3, 20)
freq_by_decade_n3 <- textstat_frequency(dfm_n3, n=5, groups = "decade") 
head(freq_by_decade_n3, 20)
# maybe we can do this by decade after removing words that don't give much insight? (TA)
# I think that's a good idea, we can also try do those periods of time we are interested in (EH)-I like this better! (TA)

# plot of most frequent words
test_dfm %>% textstat_frequency(n = 25) %>%
  ggplot(aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() +
  coord_flip() +
  labs(x = NULL, y = "Frequency") +
  theme_minimal()

# plot of most frequent words(bigrams)
dfm_n2 %>% textstat_frequency(n = 25) %>%
  ggplot(aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() +
  coord_flip() +
  labs(x = NULL, y = "Frequency") +
  theme_minimal()

# plot of most frequent words (trigrams)
dfm_n3 %>% textstat_frequency(n = 25) %>%
  ggplot(aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() +
  coord_flip() +
  labs(x = NULL, y = "Frequency") +
  theme_minimal()

# wordcloud of most common words
set.seed(144)
textplot_wordcloud(test_dfm, max_words=100)

# -----------------------------------------------------
# calculate lexical diversity
test_lexdiv <- textstat_lexdiv(test_dfm)

plot(test_lexdiv$TTR, type = 'l', xaxt = 'n', xlab = NULL, ylab = "TTR")
grid()
axis(1, at = seq_len(nrow(test_lexdiv)), labels = docvars(test_dfm, "doc_type"))
 # need to sort the dfm by doc_type in order for this to work, I think? (TA)
 # many different measures...which one should we use? (TA)
 # yeah, I think doc_type makes sense for this measure, but it might not be a super valuable 
 # metric for us unless we want to dive into the complexity of the language (EH)

# document feature similarity
test_dist <- textstat_dist(test_dfm)
# I stopped here. I need to read up on what exactly this is doing (TA)
# I think it is doing a hierarchical cluster analysis, I can share some info on this if you want (EH)
clust <- hclust(test_dist)
plot(clust, xlab = "Distance", ylab = NULL)
# but we would need to change the titles or just use one part of the title to be able to see the clusters

# -----------------------------------------------------
#relative frequency analysis
require(lubridate)

# try this relative frequency analysis with our key time periods 
# time periods: pre-OMVS (before 1972); financing/planning (1970s-1981); construction (1981-1987); 
# post-construction assessments (1987-1990s)
# PASIE (1998-2002); SDAGE (2002-);PGIRE (2006-2013); 
# upper Senegal hydroelectric dam construction (2010-2018)

# https://rdrr.io/cran/quanteda/man/textstat_keyness.html
# https://rdrr.io/cran/quanteda/man/textplot_keyness.html

# trying keyness by pre and post construction periods 
period <- ifelse(docvars(test_corpus, "year") < 1987, "pre-construction", "post-construction")
dfmat1 <- dfm(test_corpus, groups = "period", remove = c(stopwords("french"), stopwords1, dropwords1), remove_punct = TRUE)
head(dfmat1) # make sure 'pre-construction' is in the first row
head(tstat1 <- textstat_keyness(dfmat1), 10)
tail(tstat1, 10)

## hmm this period grouping worked before and now it's not, I'll try to fix it again (EH)
dfmat1 <- test_corpus %>%
  dfm(groups = "period", remove = c(stopwords("french"), stopwords1, dropwords1), remove_punct = TRUE)
tstat1 <- textstat_keyness(dfmat1, target = "pre-construction")
textplot_keyness(tstat1, margin = 0.2, n = 10) # still picking up too many errors 

# trying keyness by document type 
dfmat2 <- dfm(test_corpus, groups = "doc_type", remove = c(stopwords("french"), stopwords1, dropwords1),
              remove_punct = TRUE)
tstat2 <- textstat_keyness(dfmat2, target = "assessment") # can use lr instead of chi 2
textplot_keyness(tstat2, n = 10) # still picking up too many errors 

# very confused about how the "attr()" function works for this -- the results seem to 
# be the same with our without it
#textplot_keyness(tstat_key)

# -----------------------------------------------------
# colocation analysis (using tokens not dfm, so stopwords and others not dropped, so it's messy)
tstat_col <- tokens_select(test_tokens, pattern = '^[A-Z]', 
                                valuetype = 'regex', 
                                case_insensitive = TRUE, 
                                padding = TRUE) %>% 
  textstat_collocations(min_count = 100)
head(tstat_col, 20) # this is helpful in figuring out what to drop 

# -----------------------------------------------------
# searching for specific words (unigrams, bigrams, trigrams)

# We can do this two ways: (1) look for specific words AND/OR (2) look for specific
# nexus words
mydict <- dictionary(list(projet= "projet", gestion="gestion", programme="programme",
                          plan = "plan"))
head(textstat_frequency(dfm(test_corpus, dictionary = mydict)))

# (1) Looking for specific words (I just picked words for which I already knew the freq)
mydict <- dictionary(list(projet= "projet", gestion="gestion", programme="programme",
                          plan = "plan"))
head(textstat_frequency(dfm(test_corpus, dictionary = mydict)))

# break out into more descriptive categories so show specific topics and possible 
# nexus points: agriculture, nutrition, waterborne disease, irrigation, hydrology, 
# electricity generation, sanitation, human development 

# (2) Look for words falling into pre-defined nexus categories
# Going through the FEW-H Keyword Glossary to define the dictionary
# https://docs.google.com/spreadsheets/d/19UCudRYa-zKvLO1sIEa0knzMhB75ah6Hc7EKqZbY9b8/edit?usp=sharing
# ------------------------------
# unigrams 
# added new terms (10/17/2019)
mydict <- dictionary(list(food = c("agriculture",
                                   "agro-industries",
                                   "autoconsommation",
                                   "cultivee",
                                   "famine",
                                   "hivernage",
                                   "irrigation",
                                   "maraichage",
                                   " monoculture",
                                   "replantation",
                                   "riziculture",
                                   "rizieres",
                                   "sucreries",
                                   "agro-industriels",
                                   "arachide",
                                   "betail",
                                   " champ",
                                   "chevre",
                                   "cultivée",
                                   "culture",
                                   "echec",
                                   "fertilisants",
                                   "hydro-agricoles",
                                   "marche",
                                   "mil",
                                   "mouton", 
                                   "riz",
                                   "riziculture",
                                   "salinisation",
                                   "sorgho",
                                   "vache"),
                          
                        health = c("épidémiologique",
                                    "schistosomiase",
                                    "bilharzia",
                                    "bilharziose",
                                    "paludisme",
                                    "nutrition",
                                    "assainnissement",
                                    "bilharziose",
                                    "diarrhees",
                                    "maladies",
                                    "medicaments",
                                    "moustiquaires",
                                    "nutrition",
                                    "paludisme",
                                    "recrudescence",
                                    "sante",
                                    "schistosomiase",
                                    "traitement",
                                    "vecteurs",
                                    "alimentation",
                                    "anemie",
                                    "ankylostomiase",
                                    "Anopheles",
                                    "ascaridaise",
                                    "avitaminose",
                                    "besoins",
                                    "bilharzioses",
                                    "bilhraziose",
                                    "Biomphalaria",
                                    "Bulinus",
                                    "cas",
                                    "danger",
                                    "déparasités",
                                    "elimination",
                                    "emergence",
                                    "endemicite",
                                    "endemie",
                                    "epidemie",
                                    "épidémiologique",
                                    "eradication",
                                    "escargot",
                                    "géohelminthiases",
                                    "Glossina",
                                    "haematobium",
                                    "holo-endemicite",
                                    "hopital", 
                                    "hote",
                                    "hyper-endemicite",
                                    "hypo-endemicite",
                                    "incidence",
                                    "intensite",
                                    "intestinale",
                                    "kwashiorkor",
                                    "trichophalosela",
                                    "larvae",
                                    "malacologie",
                                    "maladie",
                                    "malnutrition",
                                    "meso-endemicite",
                                    "mollusques",
                                    "morbidite",
                                    "morbidite",
                                    "mortalite",
                                    "mouche",
                                    "moustiquaires",
                                    "moustique",
                                    "nourriture",
                                    "onchocercose",
                                    "paludisme",
                                    "parasitologiques",
                                    "parasitose",
                                    "prevention", 
                                    "privations",
                                    "propagation",
                                    "ration",
                                    "recolte",
                                    "recrudescence",
                                    "reinfestation",
                                    "sanitaire",
                                    "schistosomiase",
                                    "sous-nutrition",
                                    "subsister",
                                    "traitement",
                                    "transmission",
                                    "trypanosomiase",
                                    "urinaire",
                                    "vaincre",
                                    "vecteur"),
                        
                          water = c("abreuvement",
                                    "amont",
                                    "aval",
                                    "cote",
                                    "crue",
                                    "desertification",
                                    "endiguement",
                                    "forage",
                                    "inondation",
                                    "lâchures",
                                    "limnigramme",
                                    "marée",
                                    "navigabilité",
                                    "navigation",
                                    "pluies",
                                    "puits",
                                    "reservoir",
                                    "secheresse",
                                    "tributaire",
                                    "vannes",
                                    "vidange",
                                    "aquifere",
                                    "crue",
                                    "debit",
                                    "endiguements",
                                    "estuaire",
                                    "evaporation",
                                    "puit",
                                    "rebattement", 
                                    "recharge",
                                    "salinite",
                                    "sécheresse", 
                                    "superficie"),
                        
                          energy=c("hydroélectrique",
                                   "énergie","électrique", 
                                   "hydro-electrique",
                                   "electricite", 
                                   "renouvelable", 
                                   "hydroelectrique", 
                                   "turbine", 
                                   "energie", 
                                   "rentabilité")))


# note: for unigrams, should we only include worlds that unambiguously belong to a FEWH category?
## for example, "production" could refer to either food or energy (TA)

head(textstat_frequency(dfm(test_corpus, dictionary = mydict)))

# ------------------------------
# Bigrams
# added new terms (not finished 10/17/2019)

mydict_n2 <- dictionary(list(food = c("agriculture irriguee", "amenagement hydroagricole", 
                                      "amenagements irrigues","arbres fruitiers",
                                      "autosuffisance alimenatire","besoins agricoles",
                                      "culture ceralieres","culture de bas-fonds",
                                      "culture intercalaire","culture irriguee",
                                      "cultures maraicheres","cultures pluviales",
                                      "deficit cerealier","developpement agro-sylvo-pastoral",
                                      "eau agricole","économie agricole","equipement d'irrigation",
                                      "exploitation agricole","flux d'irrigation",
                                      "infrastructure hydro-agricole","intensification culturale",
                                      "intensification agricole","jardins maraichers",
                                      "perimetres irrigues","perimetres maraichers",
                                      "perimetres publiques", "petit agriculteurs","plan agricole",
                                      "potential agricole","potentiel irrigable","pression agricole",
                                      "production maraichere","produits agricoles",
                                      "produits alimentaires","projets agro-industriels",
                                      "projets d'irrigation","projets hydro-agricoles",
                                      "répartition culturale","securite alimentaire",
                                      "services d'irrigation","solutions d'irrigation",
                                      "activités agricoles","amenagement agricole",
                                      "aménagements agricoles","aménagements hydroagricoles",
                                      "autosuffisance alimentaire","bonnes terres","champ negligee",
                                      "development agricole","l’autosuffisance alimentaire",
                                      "périmètres irrigués","production agricole","zone agricole"
                                      ),
                          
                          health = c("maladies parasitaires","santé publique","alimentation humaine",
                                     "baignade assainies", "besoins alimentaires", 
                                     "conditions socio-sanitaires","conditions sanitaires",
                                     "education sanitaire", "endroit assaini", "gestion hygiene", 
                                     "impacts sanitaires", "maladies hydriques", "personnes exposees", 
                                     "problemes sanitaires", "sante humaine", "sante publique", 
                                     "autorites sanitaires", "bonne recolte", "calories suffisant", 
                                     "carence proteinique", "carences vitaminiques", 
                                     "chiffres elevees", "conditions favorables", 
                                     "consommation alimentaire", "consommation moyenne", 
                                     "contact mollusque-homme","degrees alimentaires", 
                                     "deparasitage repete", "dissemination d'infection", 
                                     "district sanitiare", "eah propre","eau infestee","eau saine", 
                                     "emission cercarienne", "endemicite forte", "etat nutritionelle", 
                                     "facteurs sanitaires", "faible prevalence", "forte prevalence", 
                                     "future incidence", "indicator parasitologique", 
                                     "indice d'infestation", "infection d'eleve", 
                                     "infection humaine", "infections nombreux", 
                                     "installations sanitaires", "intensite d'infestation", 
                                     "lutte contre", "lutte efficace", "maladie endemique", 
                                     "maladie grave", "maladies hydriques", "mesure prophylactique", 
                                     "mollusques hotes", "moyens alimentaires", "nutrition humaine", 
                                     "plan sanitaire", "repercussions sanitaires", "sante publique", 
                                     "se reinfecter", "statistique sanitaire", "surveillance epidemiologique", 
                                     "taux d'infection", "taux d'infestation", "taux d'infestation", 
                                     "transmission reduite", "transmission saisonniere", "zone endemique"
                                     ),
                          
                          water = c("actuel canal","apports hydriques", "bassin superieur", 
                                    "bief aval","bras secondaire","canal d'amenee", "chateau d'eau", 
                                    "conditions hydrauliques", "cote amont", "cote aval", 
                                    "cours superieur","critères hydrauliques","crue annuelle", 
                                    "crue artificielle","crue naturelle","crues exceptionnelles", 
                                    "crues extremes","crues faibles","crues observables", 
                                    "débit lâché","débit maximal","debit minimum", "débit résiduel", 
                                    "deficits pluviometriques", "desequilibre hydrologique", 
                                    "disponibilite d'eau","eau potable", "eau regularisee", 
                                    "eau souterraine", "eau superficielle", "efficience hydraulique", 
                                    "etiages severes", "gestion hydraulique", "grands affluents", 
                                    "infrastructure hydraulique", "inondation satisfaisante", 
                                    "mecanismes hydrologiques", "nappes souterraines", "niveau aval", 
                                    "niveau d'eau", "nouveau canal", "ouvrages hydrauliques", 
                                    "periodes d'etiage","plan d'eau","plan hydraulique/d'eau", 
                                    "pluviometrie annuelle", "régime établi", "régime transitoire", 
                                    "reseau hydrographique", "reservoirs aquiferes", "rive droite", 
                                    "aquifere alluvial", "canaux d'irrigation", "course d'eau", 
                                    "depot alluvial", "eau fraichee", "eau propre", "eau salee", 
                                    "eau stagnante", "l'eau d'irrigation", "langue salee", 
                                    "nappe phreatique", "nappe souterraines", "puit profond", 
                                    "qualite d'eau","reseau d'irrigation"
                                    ),
                          
                          energy=c("branchement electrique","capacite hydroelectrique",
                                   "centrales hydroelectriques","production d'énergie", 
                                   "developpement energetique", "dissipation d'énérgie", 
                                   "electrification prioritaire","electrification rurale", 
                                   "energie hydroelectrique","energie produite", 
                                   "energie renouvelable","equipement hydroelectrique",
                                   "ouvrage hydroelectrique","potentiel hydroelectrique",
                                   "production hydroelectrique","production d'énergie", 
                                   "production électrique", "projet hydroelectrique", 
                                   "puissance installee", "puissance maximale", 
                                   "reseaux d'electricite","reserve d'energie", 
                                   "secteur energetique", "d'amenagements hydroelectriques", 
                                   "transport d'electricite", "usine hydroelectrique",
                                   "volumes turbinés",
                                   "l’énergie électrique"
                                   )))

head(textstat_frequency(dfm(test_corpus, dictionary = mydict_n2)))

# ------------------------------
# Trigrams

mydict_n3 <- dictionary(list(food = c("cultivées en irrigué", "diète des ménages",
                                      "desertion des terres"),
                             
                             health = c("carences en calcium",
                                        "taux de prévalence",
                                        "maladies d'origine hydrique",
                                        "Plan Sanitaire Regional",
                                        "taux de morbidite",
                                        "taux de mortalite",
                                        "traitement de masse",
                                        "les cas observees",
                                        "les cas cliniques",
                                        "campagnes de traitement",
                                        "programme de surveillance",
                                        "sante de population",
                                        "densite de vecteurs",
                                        "multiplication de vecteurs",
                                        "habitat de vecteurs",
                                        "niveau de vie",
                                        "dimunition de prevalence",
                                        "chiffre de prevalence",
                                        "amelioration de sante",
                                        "poste de sante",
                                        "chiffre de mortalite",
                                        "besoins en brousse",
                                        "besoins en latrine"),
                             
                             water = c("niveau des eaux",
                                       "eau de surface",
                                       "access de eau",
                                       "accumulations permanents d'eau",
                                       "l'eau de drainage",
                                       "lutte anti-vectorielle",
                                       "d’évaluation des impacts",
                                       "conditions de vie"),
                             
                             energy = c("production d'energie electrique")))

head(textstat_frequency(dfm(test_corpus, dictionary = mydict_n3)))

