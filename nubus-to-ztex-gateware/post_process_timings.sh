#!/bin/bash

FILE=$1

sed -e 's/ad_n\([0-9]*\)/ad_3v3_n[\1]/' \
	-e 's/clk_n/clk_3v3_n/' \
	-e 's/rqst_n/rqst_3v3_n/' \
	-e 's/start_n/start_3v3_n/' \
	-e 's/ack_n/ack_3v3_n/' \
	-e 's/clk_n/clk_3v3_n/' \
	-e 's/tm_n\([0-9]*\)/tm\1_3v3_n/' \
	-e 's/clk_3v3_n/nubus_clk/g' \
	$FILE | grep -v 'nubus_clk.*nubus_clk' | grep '^set' | tee $2


