#!/bin/sh
cd ${HNBLOGS}
export RACK_ENV=production
bundle exec ruby server.rb
