#!/bin/bash
INPUT_FILE='/root/file.csv'
IFS=','
while read sourceregistryurl destinationregistry sourcerepo sourceimagetag
do
	echo "sourceregistryurl: $sourceregistryurl"
	echo "destinationregistry: $destinationregistry"
	echo "sourcerepo: $sourcerepo"
	echo "sourceimagetag: $sourceimagetag"
	docker pull $sourceregistryurl:80/$sourcerepo:$sourceimagetag
	docker tag $sourceregistryurl:80/$sourcerepo:$sourceimagetag $destinationregistry:80/$sourcerepo:$sourceimagetag
	docker push $destinationregistry:80/$sourcerepo:$sourceimagetag
	docker image prune --force -a
done < $INPUT_FILE

