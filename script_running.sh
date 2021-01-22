find . -type f -name '*.faa.gz' > allpaths.txt

while read line; 
do
	BASE=${line%%.gz}
	gzip -kd $line ## разархивация
	./signalp -fasta $BASE -org gram- -format short -prefix $BASE ## анализ в signalp
	tr "," "_" < $BASE > $BASE.out0 ## замена запятых на нижние подчеркивания для корректного определения новой строки
	rm -f $BASE ## удаление промежуточного файла
	awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < $BASE.out0 > $BASE.out1  ## - multiline faa to singleline
	rm -f $BASE.out0 ## удаление промежуточного файла
	tr "\n" "\t" < $BASE.out1 > $BASE.out2
	rm -f $BASE.out1 ## удаление промежуточного файла
	tr ">" "\n" < $BASE.out2 > $BASE.singleline
	rm -f $BASE.out2 ## удаление промежуточного файла
	tail -n +2 "$BASE"_summary.signalp5 > "$BASE"_summary.signalp5.cut ## считать только со второй строки
	awk 'FNR==NR{A[FNR]=$0;next} {print $0,A[FNR]}' OFS='' "$BASE"_summary.signalp5.cut $BASE.singleline > $BASE.union ## объединять файлы
	rm -f $BASE.singleline ## удаление промежуточного файла
	rm -f "$BASE"_summary.signalp5.cut ## удаление промежуточного файла
	rm -f $BASE ## удаление промежуточного файла
	rm -f "$BASE"_summary.signalp5 ## удаление промежуточного файла
	echo
done < allpaths.txt


find . -type f -name '*.union' > finals.txt

while read line; 
do
	FILE=${line}
	tail -n +2 $FILE > $FILE.final ## удаление первой строки
	cat $FILE.final >> allpredictions0.txt ## объединение файлов в единый
	rm -f $FILE.final ## удаление промежуточного файла 
	echo
done < finals.txt

sed '1 i name	sequence	ID	Prediction	SP(Sec/SPI)	TAT(Tat/SPI)	LIPO(Sec/SPII)	OTHER	CS Position' < allpredictions0.txt > allpredictions.txt ## добавление заголовка
rm -f allpredictions0.txt ## удаление промежуточного файла
