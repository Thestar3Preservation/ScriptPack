#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION
bashcolorset

#도움말 페이지
help(){
	cat <<-EOF
		사용법 : $(basename "$0") -h, -v
		  또는 : $(basename "$0") [계산식]
		  또는 : $(basename "$0") [변수] [계산식]
		부울 대수식을 계산하거나, 진리표를 생성.

		옵션 :
		      -h, --help      이 도움말을 표시하고 끝냅니다
		      -v, --version   버전 정보를 출력하고 끝냅니다

		규칙 :
		* 변수는 오직 알파벳 한문자만 가능하며, 대소문자를 구분합니다. 예를 들어, A와 a는 서로 다른 변수입니다. AA라는 변수는 지정할수 없습니다.
		* A+B또는 A|B는 논리합, A^B는 배타적 논리합, !A 또는 ~A는 부정, A*B 또는 A&B는 논리곱을 의미합니다.
		* 식을 입력할때, AB식으로 연속으로 변수 혹은 값을 적는 경우, A*B로 자동으로 변환하여 처리합니다.

		예제 :
		ex1) 주어진 변수값과 계산식의 결과를 구합니다.
		     $(basename "$0") A=0 B=1 A+B
		ex2) 주어진 계산식의 진리표를 구합니다.
		     $(basename "$0") A+B
	EOF
}

#아무런 인자도 주어지지 않았을 경우 도움말을 호출.
[[ $# == 0 ]] && { help; exit 1; }

#옵션을 실행
case $1 in
	-h | --help)
		help
		exit 0;;
	-v | --version)
		cat <<-EOF
			부울 대수식 계산기

			2.8 계산이 비정상적으로 수행되던 문제 해결.
			2.7 마이너스로 결과가 값이 잘못 표시되던 문제 해결.
			    도움말의 잘못된 부분을 정정.
			    도움말의 내용 일부를 이해하기 쉽도록 수정.
			2.6 논리부정 연산이 되지 않던 문제 해결.
			2.5 도움말을 예쁘게 수정.
			    결과를 색상을 통해, 구분할수 있도록 함.
			2.4 보다 간단하게 논리연산을 수행하도록 개선.
			2.3 논리식을 보다 예쁘게 표현하도록 개선.
			2.2 설명을 변경.
			    논리기호를 재정의하고, 수정함.
			    A'를 논리부정으로 보던 기능을 삭제함.
			    보다 간단하게 논리연산을 하도록 개선.
			2.1 배타적 논리합(XOR) 연산을 지원.
			2.0 변수가 주어졌을 경우, 계산 이뤄지지 않던 문제 해결.
			1.9 부정논리를 표현하는 방식을 추가( A' = !A )
			1.8 옵션에 접근하기 쉽도록, 단축옵션을 추가.
			1.7 도움말에서 옵션 설명을 추가.
			1.6 인자를 주지 않았을 경우, 도움말 호출.
			1.5 옵션 확인을 보다 간략화.
			1.4 백업용 주석코드를 제거.
			1.3 계산과정을 간략화.
			1.2 진리표 구하기 기능 추가.
			1.1 도움말과 버전 페이지를 추가.
			1.0 AND, OR, NOT연산을 지원. 묶음표시 '()' 지원.
		EOF
		exit 0;;
esac

:<<\EOF
bool_calculate(){
	local expression cal
	expression=$(sed -e 's/\([a-z]\)\([a-z]\)/\1\&\2/ig' -e 'y/*+!/&|~/' -e "y/$1/$2/" <<<"$3")
	while true; do
		echo -n '<<'; sed -e 's/^.*[(]\([^)]*\)[)].*$/\1/' <<<"$expression"
		cal=$(eval "echo \$(($(sed -e 's/^.*[(]\([^)]*\)[)].*$/\1/' -e 's/~0/1/g' -e 's/~1/0/g' -e 's/~0/1/g' -e 's/~1/0/g' <<<"$expression")))")
		expression=$(sed -rn "s/^(.*)[(][^)]*[)](.*)$/\1$cal\2/p" <<<"$expression")
		[ -z "$expression" ] && { echo $cal; break; }
	done
	#eval "echo \$(($(sed -e 's/\([a-z]\)\([a-z]\)/\1*\2/ig' -e 's/\([a-z]\)\([a-z]\)/\1*\2/ig' -e 'y/*+!/&|~/' -e "y/$1/$2/"<<<"$3")))"
	#-e 's/~0/1/g' -e 's/~1/0/g' -e 's/~0/1/g' -e 's/~1/0/g'
}
EOF

:<<\EOF
#논리계산 : $1은 변수명, $2는 변수의 값. 두 인자는 서로 순차적으로 일대일 매칭됩니다. $3은 대수식.
bool_calculatea(){
	#local expression=$(sed -e "y/$1/$2/" <<<"$3")
	perl -e "\$_ = '$expression'; print \$_; y/$1/$2/; \$expr =~ \$_; while( true ) { \$expr =~ /^(.*)[(]([^)]+)[)](.*)$/; \$2 =~ s/~0/1/g; s/~1/0/g; eval '\$_ = \$2'; \$expr = "\$1.\$_.\$3"; if ( \$expr =~ ~/[(]/ ) { print \$expr; break; }; }"
# 	while true; do
# 		val=$(sed -e 's/.*[(])//' -e 's/[)].*//' -e 's/~0/1/g' -e 's/~1/0/g' <<<"$expression") #가장 안쪽에 있는 괄호의 내용을 추출하고, 부정논리를 계산함.
# 		eval "val=\$(($val))"
#
# 		return=$(sed 's/[(]')
# 	done
# 	eval "val=\$(($(sed -e "y/$1/$2/" <<<"$3")))"
# 	if [ $val = -2 ]; then #1을 부정하면, -2
# 		echo 0
# 	elif [ $val = -1 ]; then #0을 부정하면, -1
# 		echo 1
# 	else #0또는 1인 경우와 그외 기타.
# 		echo $val
# 	fi

}

bool_calculate(){
	local expression cal
	expression=$(sed -e 's/\([a-z]\)\([a-z]\)/\1\&\2/ig' -e 'y/*+!/&|~/' -e "y/$1/$2/" <<<"$3")
	expression="\$($(sed -e 's///'))"
	code(){
		eval echo -n "\$(($(bashsed '//~0/1/' '//~1//0/')))"
	}
	while true; do
		echo -n '<<'; sed -e 's/^.*[(]\([^)]*\)[)].*$/\1/' <<<"$expression"
		cal=$(eval "echo \$(($(sed -e 's/^.*[(]\([^)]*\)[)].*$/\1/' -e 's/~0/1/g' -e 's/~1/0/g' -e 's/~0/1/g' -e 's/~1/0/g' <<<"$expression")))")
		expression=$(sed -rn "s/^(.*)[(][^)]*[)](.*)$/\1$cal\2/p" <<<"$expression")
		[ -z "$expression" ] && { echo $cal; break; }
	done
	#eval "echo \$(($(sed -e 's/\([a-z]\)\([a-z]\)/\1*\2/ig' -e 's/\([a-z]\)\([a-z]\)/\1*\2/ig' -e 'y/*+!/&|~/' -e "y/$1/$2/"<<<"$3")))"
	#-e 's/~0/1/g' -e 's/~1/0/g' -e 's/~0/1/g' -e 's/~1/0/g'
}
EOF

#실행가능한 계산식으로 수정함.
rematchexpr(){ expression=$(sed -r -e 'y/*+!/&|~/' -e 's/([a-z)])([a-z~(])/\1\&\2/ig' -e 's/([a-z)])([a-z~(])/\1\&\2/ig' <<<"$expression"); }

:<<\EOF
boola_calculate(){
	local expression temp

	#변수를 치환처리한다.
	expression=$(sed -e 'y/&|~/*+!/' -e "y/$1/$2/" <<<"$3")

	while true; do

		#가장 안쪽의 괄호를 추출해내고, NOT->AND->OR순으로 연산함.
		temp=$(sed -r -e 's/^.*[(]([^)]*)[)].*$/\1/' -e 's/(!0|0'\'')/1/g' -e 's/(!1|1'\'')/0/g' -e 's/[01]*0[01]*/0/g' -e 's/1+/1/g' -e 's/(0\^0|1\^1)/0/g' -e 's/(0\^0|1\^1)/0/g' -e 's/(0\^0|1\^1)/0/g' -e 's/[01]\^[01]/1/g' -e 's/[01]\^[01]/1/g' -e 's/[01]\^[01]/1/g' -e 's/[+]//g' -e 's/[01]*1[01]*/1/g' -e 's/0+/0/g' <<<"$expression")

		#가장 안쪽의 괄호를 구해낸 결과로 치환함.
		expression=$(sed -rn "s/^(.*)[(][^)]*[)](.*)$/\1$temp\2/p" <<<"$expression")

		#괄호가 존재하지 않는다면, 계산된 결과를 출력.
		[ -z "$expression" ] && { echo $temp; break; }

	done
}
EOF

#마지막 인수가 대수식으로 저장됨.
expression=$(sed 'y/&|~/*+!/' <<<"${!#}" | tr -d '* ')

#대수식이 올바른지 검정.
if grep -qi '[^a-z01()^~|&!+*]' <<<"$expression"; then
	help
	echo -e "\n$COL_RED올바르지 않은 대수식입니다.$COL_RESET" >&2
	exit 1
fi

#대수식에 포함된 변수의 이름을 추출하고 정렬.
value_name=$(grep -oi '[A-Z]' <<<"$expression" | sort -u | tr -d '\n')

#대수식에 포함된 변수가 몇개인지 계산.
value_num=$(echo -n "$value_name" | wc -m)



#지정된 입력값이 존재한다면
if [[ $# > 1 ]]; then

	#입력된 변수를 value에 저장
	value=$(sed '$d' <<<"$*")

	#변수가 올바르며, 충분한지 확인
	if [[ $(grep -ixc '[a-z]=[01]' <<<"$value") != $value_num ]]; then
		help
		echo -e "\n$COL_RED올바르지 않은 변수이거나 충분하지 않은 변수가 주어졌습니다.$COL_RESET" >&2
		exit 1
	fi

	#주어진 조건을 다듬어서 표현
	echo -ne "$COL_CYAN대수식 :$COL_RESET $expression\n$COL_CYAN입력 :$COL_RESET $(tr '\n' ' ' <<<"$value")\n$COL_CYAN출력 :$COL_RESET "

	#실행가능한 계산식으로 수정함.
	#expression=${!#}
	rematchexpr

	#주어진 경우대로 계산해서 결과를 출력
	bool_calculate "$(cut -d '=' -f 1 <<<"$value" | tr -d '\n')" "$(cut -d '=' -f 2 <<<"$value" | tr -d '\n')" "$expression"

#계산식만 주어진다면
else

	#각각의 경우를 계산해서 다듬고 진리표를 출력
	echo -e "$COL_CYAN대수식 :$COL_RESET $expression$COL_CYAN\n\n\t진리표\n$(sed 's/\(.\)/\1\t/g' <<<"$value_name")출력$COL_RESET"

	#실행가능한 계산식으로 수정함.
	rematchexpr

	#2의 n승만큼 되풀이하며, 2진수 값을 증가시킴.
	for((count=0; count<$(bc <<<"2^$value_num"); count++)); do

		#현재 계산중인 경우를 다듬어서 출력
		value_context=$(perl -e "printf \"%0${value_num}b\", $count")
		echo -n $(sed 's/\(.\)/\1\t/g' <<<"$value_context")

		#주어진 경우대로 계산해서 결과를 출력
		bool_calculate $value_name $value_context "$expression"
	done
fi

exit