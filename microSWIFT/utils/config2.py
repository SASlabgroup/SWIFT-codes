########################################################################
# This class handles configuration files in the so-called
# "INI" style format.
#
# File can contain [Section]'s and initializing "templates",
# which are defined by a leading "$"
########################################################################

import os.path
import ConfigParser
import StringIO

'''
# Class def start
'''
class Config:

    ########################################################################
    # Constructor
    ########################################################################
    def __init__(self):
        # Does nothing
        return
        
    ########################################################################
    # Load the file & parse into key/value pairs per section
    ########################################################################
    def loadFile(self, configFilename):
        """
        Modify the input file as needed, pass it to the config parser & return the output.
        See https://docs.python.org/2/library/configparser.html
        Any expansion parameters (e.g. $BASENAME) are put into the DEFAULT section (because that is how the config
        parser works)
        :param configFilename: The file to modify, using $ for the substitution flag
        :return: a python config object.   To get a value in a section use:
        config.get('Section_name', 'Param_name')
        Every parameter needs to be in a section, except for the expansion params, which need to start with $ as the first
        character on the line.
        """

        # Sanity check
        if( not os.path.exists(configFilename) ):
            print ('ERROR: File "%s" not found' % configFilename)
            return False

        # Open the file & read it all in
        with open(configFilename) as handle:
            input_lines = handle.readlines()
            
        param_sub_map = {}
        default_section = []
        default_section.append('[DEFAULT]\n')
        
        section_list = []
        for line in input_lines:
            if line and (line.startswith('#') or line.startswith(';') or line.startswith('\n')):
                    continue
            if line.startswith('$'):
                default_section.append(line.replace('$', ''))
                split_line = line.split('=')
                new_token = '%(' + split_line[0].strip()[1:] + ')s'
                param_sub_map[split_line[0].strip()] = new_token
            elif '$' in line:
                new_line = line
                for token, replacement in param_sub_map.items():
                    new_line = line.replace(token, replacement)
                section_list.append(new_line)
                    
            else:
                section_list.append(line)
                        
        combined_sections = default_section + section_list
        stringObj = StringIO.StringIO(''.join(combined_sections))

        # Save the config object
        self.config = ConfigParser.SafeConfigParser()
        self.config.readfp(stringObj)

        return True

        
    # =============================================================
    # Get the value associated with the specified
    # section and keyword as a string
    #
    # If the section/keyword does not exist in the dictionary,
    # then "None" is returned.
    # =============================================================
    def getString( self,
                   section,
                   key ):
        try:
            value = self.config.get( section, key )
        except:
            print('ERROR: Section/Key "%s/%s" combination not found' % (section,key))
            return None
        return value

        
    # =====================================================================
    # Get the value associated with the specified
    # section and keyword as a float.
    #
    # If the keyword does not exist in the dictionary, or the value cannot
    # be represented as an int, then "None" is returned.
    # =====================================================================
    def getInt( self,
                section,
                key ):

        # Get the value as a string
        strVal = self.getString(section,key)
        # Bail if it's not there
        if( strVal is None ):  
            return None

        # Try to convert to int
        try:
            intVal = int(strVal)
            return intVal
        # No-can-do...
        except:
            print ('ERROR: Value "%s" for key "%s" cannot be converted to int' \
                % (strVal,key))
            return None

        
    # =====================================================================
    # Get the value associated with the specified
    # section and keyword as a float.
    #
    # If the keyword does not exist in the dictionary, or the value cannot
    # be represented as a float, then "None" is returned.
    # =====================================================================
    def getFloat( self,
                  section,
                  key ):

        # Get the value as a string
        strVal = self.getString(section,key)
        # Bail if it's not there
        if( strVal is None ):  
            return None

        # Try to convert to float
        try:
            floatVal = float(strVal)
            return floatVal
        # No-can-do...
        except:
            print ('ERROR: Value "%s" for key "%s" cannot be converted to float' \
                % (strVal,key))
            return None

        
