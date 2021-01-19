find . -type f -name '*.faa.gz' > allpaths.txt

while read line; 
do
	BASE=${line%%.gz}
	gzip -kd $line
	signalp -fasta $BASE -org gram- -format short -prefix $BASE
	echo
done < allpaths.txt


## 1. awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < file.fa - multiline fa to singleline
## 2. tr "\n" "\t" < in.fa > out.fa
## 3. tr ">" "\n" < in.fa > out.fa
