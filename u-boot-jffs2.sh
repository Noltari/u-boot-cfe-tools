#!/bin/sh

create_bin_dir=1

usage() {
	echo "Usage: $(basename $0)"
	echo "\t[-d]: Disable bin dir creation"
	echo "\t-e <erase block>: Erase block size (e.g. 128k)"
	echo "\t-i <input file>: Input file (e.g. cferam.000)"
	echo "\t-o <output file>: Output file (e.g. cferam.jffs2)"
}

jffs2_create() {
	local root_dir=$(mktemp -d)

	case "${erase_block}" in
		*k*)
			erase_block=$(echo "$(echo $erase_block | tr -d k) * 1024" | bc -l )
			;;
	esac

	if [ $create_bin_dir -eq 1 ]; then
		mkdir -p $root_dir/bin
	fi

	cp $input_file $root_dir

	mkfs.jffs2 \
		--big-endian \
		--pad \
		--no-cleanmarkers \
		--eraseblock=$erase_block \
		--root=$root_dir \
		--output=$output_file \
		--compression-mode=none

	rm -rf $root_dir
}

main() {
	while getopts ":de:hi:o:" opt; do
		case "${opt}" in
			'e')
				erase_block=$OPTARG
				;;
			'h')
				usage
				;;
			'i')
				input_file=$OPTARG
				;;
			'o')
				output_file=$OPTARG
				;;
			'd')
				create_bin_dir=0
				;;
		esac
	done

	jffs2_create 

	exit 0
}

main $@
