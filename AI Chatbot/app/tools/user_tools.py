"""
User Management Tools
Tools for fetching and managing user account information.
"""

from langchain.tools import Tool
from ..database import get_user_account


def fetch_user_account(phone: str) -> str:
    """
    Fetch user account information using phone number.
    
    Args:
        phone: User's phone number (format: +880XXXXXXXXXX)
        
    Returns:
        JSON string containing user account details or error message
    """
    try:
        user_data = get_user_account(phone)
        
        if user_data:
            return f"""
User Account Found:
- Name: {user_data.get('name', 'N/A')}
- Phone: {user_data.get('phone', 'N/A')}
- Account ID: {user_data.get('account_id', 'N/A')}
- Plan: {user_data.get('plan', 'N/A')}
- Status: {user_data.get('status', 'N/A')}
- Balance: {user_data.get('balance', 0)} BDT
- Connection Type: {user_data.get('connection_type', 'N/A')}
"""
        else:
            return f"No user account found for phone number: {phone}"
            
    except Exception as e:
        return f"Error fetching user account: {str(e)}"


# Create the LangChain Tool
GetUserAccountTool = Tool.from_function(
    name="GetUserAccount",
    func=fetch_user_account,
    description="""
    Use this tool to fetch user account information using their phone number.
    Input should be a phone number in format: +880XXXXXXXXXX or 01XXXXXXXXX.
    Returns user details including name, plan, status, and balance.
    Use this when user asks about their account, balance, or plan details.
    """
)
