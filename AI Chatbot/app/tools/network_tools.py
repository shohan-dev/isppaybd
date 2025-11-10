"""
Network Management Tools
Tools for checking connection status and network diagnostics.
"""

from langchain.tools import Tool
from ..database import check_connection_status


def fetch_connection_status(phone_or_account_id: str) -> str:
    """
    Check the internet connection status for a user.
    
    Args:
        phone_or_account_id: User's phone number or account ID
        
    Returns:
        Connection status details including uptime, speed, and issues
    """
    try:
        status = check_connection_status(phone_or_account_id)
        
        if status:
            connection_state = status.get('is_online', False)
            status_text = "ONLINE ✓" if connection_state else "OFFLINE ✗"
            
            response = f"""
Connection Status: {status_text}

Details:
- Router Status: {status.get('router_status', 'Unknown')}
- Signal Strength: {status.get('signal_strength', 'N/A')}
- Last Online: {status.get('last_online', 'N/A')}
- Uptime: {status.get('uptime', 'N/A')}
- Download Speed: {status.get('download_speed', 'N/A')} Mbps
- Upload Speed: {status.get('upload_speed', 'N/A')} Mbps
"""
            
            # Add issues if any
            issues = status.get('issues', [])
            if issues:
                response += f"\n⚠️ Detected Issues:\n"
                for issue in issues:
                    response += f"  - {issue}\n"
            
            return response
        else:
            return f"Could not retrieve connection status for: {phone_or_account_id}"
            
    except Exception as e:
        return f"Error checking connection status: {str(e)}"


# Create the LangChain Tool
ConnectionStatusTool = Tool.from_function(
    name="ConnectionStatus",
    func=fetch_connection_status,
    description="""
    Use this tool to check the internet connection status for a user.
    Input should be either a phone number or account ID.
    Returns detailed connection information including:
    - Online/Offline status
    - Router status
    - Signal strength
    - Speed metrics
    - Any detected network issues
    Use this when user reports connectivity problems or asks about their connection.
    """
)
