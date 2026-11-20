#!/bin/bash
#
# Lit la première phrase de l'article de Wikipédia sur un sujet.
#
# Le sujet vient de l'étoile de la phrase : « cherche sur wikipédia * » donne
# « victor hugo ». La recherche de Wikipédia trouve l'article, même sans
# majuscules ni titre exact.

sujet=${VOCAL_ASSISTANT_ARGUMENT:-}
if [ -z "$sujet" ]; then
    echo "Je n'ai pas compris quoi chercher."
    exit 1
fi

wikipedia=https://fr.wikipedia.org
curl_wikipedia() {
    curl -sfL --max-time 8 -A "vocal-assistant (assistant vocal personnel)" "$@"
}

if ! recherche=$(curl_wikipedia -G "$wikipedia/w/api.php" \
    --data-urlencode action=query --data-urlencode list=search \
    --data-urlencode "srsearch=$sujet" --data-urlencode srlimit=1 \
    --data-urlencode format=json); then
    echo "Wikipédia ne répond pas."
    exit 1
fi
titre=$(printf '%s' "$recherche" | jq -r '.query.search[0].title // empty')
if [ -z "$titre" ]; then
    echo "Je n'ai rien trouvé sur Wikipédia pour $sujet."
    exit 1
fi

resume=$(curl_wikipedia "$wikipedia/api/rest_v1/page/summary/$(printf '%s' "$titre" | jq -sRr @uri)" |
    jq -r '.extract // empty')

# Les crochets contiennent la prononciation en alphabet phonétique, que Piper
# lirait de travers. La première phrase s'arrête au premier point suivi d'une
# majuscule : « J.-C. » ou « XIXe s. » ne la coupent pas.
printf '%s' "$resume" |
    sed -E 's/ *\[[^]]*\]//g; s/([.!?]) +[[:upper:]À-Ý].*/\1/'
