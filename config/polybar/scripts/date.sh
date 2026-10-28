#!/usr/bin/env bash

months=(ژانویه فوریه مارس آوریل مه ژوئن ژوئیه اوت سپتامبر اکتبر نوامبر دسامبر)
calendar=$''
clock=$''

fa() {
    echo "$1" | sed 'y/0123456789/۰۱۲۳۴۵۶۷۸۹/' | fribidi --nopad --nobreak
}

gregorian=$(fa "$(date +%d) ${months[$((10#$(date +%m) - 1))]} $(date +%Y)")
time=$(fa "$(jdate +"%H:%M")")
weekday=$(fa "$(jdate +"%A")")
jalali=$(fa "$(jdate +"%d %B %Y")")

echo "$calendar $gregorian  $clock $time  $weekday  $jalali $calendar"
