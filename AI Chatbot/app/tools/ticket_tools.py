"""
Support Ticket Tools
Tools for creating and managing support tickets.
"""

from langchain_core.tools import tool
from ..database import create_support_ticket


def open_support_ticket(issue_description: str) -> str:
    """
    Create a support ticket for user issues.
    
    Args:
        issue_description: Detailed description of the user's issue
                          Should include: user identifier, issue type, and details
        
    Returns:
        Ticket creation confirmation with ticket ID and estimated resolution time
    """
    try:
        # Parse the description to extract key information
        # Format expected: "Phone: +880XXXX | Issue: Description here"
        
        ticket = create_support_ticket(issue_description)
        
        if ticket and ticket.get('ticket_id'):
            return f"""
✓ Support Ticket Created Successfully

Ticket Details:
- Ticket ID: {ticket.get('ticket_id')}
- Priority: {ticket.get('priority', 'Medium')}
- Status: {ticket.get('status', 'Open')}
- Category: {ticket.get('category', 'General')}
- Estimated Resolution: {ticket.get('estimated_resolution', '24-48 hours')}

Our support team will contact you shortly.
You can track your ticket status using the Ticket ID.
"""
        else:
            return "Failed to create support ticket. Please try again or contact support directly."
            
    except Exception as e:
        return f"Error creating support ticket: {str(e)}"


# Create the LangChain Tool using decorator
@tool
def OpenTicketTool(issue_description: str) -> str:
    """
    Use this tool to create a support ticket for issues that cannot be resolved immediately.
    Input should be a detailed description including:
    - User's phone number or account ID
    - Type of issue (connectivity, billing, technical, etc.)
    - Detailed description of the problem
    - Any troubleshooting steps already attempted
    
    Format the input as: "Phone: [phone] | Issue: [type] | Details: [description]"
    
    Use this tool when:
    - User's issue requires technician visit
    - Problem cannot be solved through agent
    - User explicitly requests to create a ticket
    - Complex issues requiring human intervention
    
    Args:
        issue_description: Detailed description of the user's issue
    """
    return open_support_ticket(issue_description)
