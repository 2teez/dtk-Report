#!/usr/bin/env python3

import os
import sys


def main(lst: list[str]) -> None:
    try:
        hour = int(lst[0])
        if (hour < 0 or hour > 23):
            print('Enter a valid report time between 0 & 23')
            sys.exit(1)
    except Exception as ex:
        print(f'Usage: {sys.argv[0]} [timer]')
        sys.exit(1)


if __name__ == '__main__':
    main(sys.argv[1:])
