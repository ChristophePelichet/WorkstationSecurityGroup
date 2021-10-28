# WorkstationSecurityGroup

Script to check that a specified type of machine is in a specific security group, to add them as needed and to make a report by email.

## Configuration

He entire configuration is done in the configuration file 
"MyScriptPath\Config\config.xml"

## Variables in config.xml

### Debug settings
- Enable or Disable debug output ( 1 Enable / 0 = Disable )
    - key="debug"

### Filter AD
- Filter workstation name 
  - Key="filter_computer_name"

- Filer security groupe name
  - security_group_name

### Email Settings
- Enable or disable sending the report by email ( 1 Enable / 0 = Disable )
    - Key="email_report"       
- Email to
    - Key="email_to"
- Email from
    - Key="email_from"
- Email subject
    - Key="email_subject"
- Email body
    - Key="email_body"
- Email server
    - Key="email_serv"
