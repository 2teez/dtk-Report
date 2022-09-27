#!/usr/bin/env python3

import os
import sys

__AUTHOR__ = 'emrys'
__VERSION__ = 0.1


class NElement:
    hourly_content: list[str] = []

    def __init__(self, name: str) -> None:
        self._name = name

    def __repr__(self) -> str:
        return '|'.join(self.hourly_content)

    def __str__(self) -> str:
        return self.__repr__()

    def _get_data(self, line) -> None:
        self.hourly_content.append(line)


def read_file(files: list[str]) -> None:
    os.chdir('./datafiles')
    print('TODO: Implement container and parse each line')
    # for file in files:
    #     with open(file) as fin:
    #         for line in fin.readlines():
    #             print(line)


def search_locate(dir: str) -> tuple[int, list[str]]:
    'search to find if csv files exist in the specified location.'
    # check if the directory exist
    if not os.path.exists(dir):
        print(f'Path specified - {dir} doesn\'t exist.')
        sys.exit(1)

    files = \
        list(file
             for file in os.listdir(dir) if file.endswith('.csv'))
    return (len(files), files)


def main(lst: list[str]) -> None:
    'Entry point for all function.'
    try:
        hour = int(lst[0])
        if (hour < 0 or hour > 23):
            print('Enter a valid report time between 0 & 23')
            sys.exit(1)
    except Exception as ex:
        print(f'Usage: {sys.argv[0]} [timer]')
        sys.exit(1)

    number_file, list_file = search_locate('datafiles')
    if (number_file) != 2:
        file_names = \
            f'/ne_5_Incoming_Calls_through_Trunk_Groups|ne_5_Outgoing_Calls_through_Trunk_Groups/'
        print(file_names+' must in the directory `datafiles`')
        sys.exit(1)
    else:
        read_file(list_file)


if __name__ == '__main__':
    main(sys.argv[1:])
