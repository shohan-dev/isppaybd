"""
Database Layer
Mock database functions for user accounts, connections, and tickets.
Replace with real database integration (PostgreSQL, MongoDB, etc.) in production.
"""

from typing import Dict, Optional, List
from datetime import datetime
import random


# ==================== MOCK DATA ====================

MOCK_USERS = {
    "+8801712345678": {
        "account_id": "USR001",
        "name": "Ahmed Hassan",
        "phone": "+8801712345678",
        "plan": "100 Mbps Unlimited",
        "status": "Active",
        "balance": 0,
        "connection_type": "Fiber Optic"
    },
    "+8801823456789": {
        "account_id": "USR002",
        "name": "Fatima Rahman",
        "phone": "+8801823456789",
        "plan": "50 Mbps Standard",
        "status": "Active",
        "balance": -500,
        "connection_type": "Cable"
    },
    "+8801534567890": {
        "account_id": "USR003",
        "name": "Karim Ahmed",
        "phone": "+8801534567890",
        "plan": "200 Mbps Premium",
        "status": "Suspended",
        "balance": -1200,
        "connection_type": "Fiber Optic"
    }
}

MOCK_CONNECTIONS = {
    "USR001": {
        "is_online": True,
        "router_status": "Connected",
        "signal_strength": "Excellent (95%)",
        "last_online": "Currently Online",
        "uptime": "15 days, 6 hours",
        "download_speed": 98.5,
        "upload_speed": 95.2,
        "issues": []
    },
    "USR002": {
        "is_online": False,
        "router_status": "Disconnected",
        "signal_strength": "Poor (20%)",
        "last_online": "2 hours ago",
        "uptime": "0 days, 0 hours",
        "download_speed": 0,
        "upload_speed": 0,
        "issues": ["Router offline", "No signal detected", "Possible cable damage"]
    },
    "USR003": {
        "is_online": False,
        "router_status": "Suspended",
        "signal_strength": "N/A",
        "last_online": "5 days ago",
        "uptime": "0 days, 0 hours",
        "download_speed": 0,
        "upload_speed": 0,
        "issues": ["Account suspended due to unpaid balance"]
    }
}


# ==================== USER ACCOUNT FUNCTIONS ====================

def get_user_account(phone: str) -> Optional[Dict]:
    """
    Retrieve user account information by phone number.
    
    Args:
        phone: User's phone number
        
    Returns:
        User account dictionary or None if not found
    """
    # Normalize phone number
    phone = normalize_phone(phone)
    
    # Mock database lookup
    user = MOCK_USERS.get(phone)
    
    if user:
        return user.copy()
    
    # In production, this would be a database query:
    # SELECT * FROM users WHERE phone = %s
    
    return None


def normalize_phone(phone: str) -> str:
    """
    Normalize phone number to consistent format.
    
    Args:
        phone: Phone number in any format
        
    Returns:
        Normalized phone number (+880XXXXXXXXXX)
    """
    # Remove spaces, dashes, parentheses
    phone = phone.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    
    # Convert 01XXXXXXXXX to +8801XXXXXXXXX
    if phone.startswith("01"):
        phone = f"+880{phone[1:]}"
    
    # Ensure +880 prefix
    if not phone.startswith("+880"):
        if phone.startswith("880"):
            phone = f"+{phone}"
    
    return phone


# ==================== CONNECTION STATUS FUNCTIONS ====================

def check_connection_status(identifier: str) -> Optional[Dict]:
    """
    Check internet connection status for a user.
    
    Args:
        identifier: Phone number or account ID
        
    Returns:
        Connection status dictionary or None if not found
    """
    # Try to find user first
    account_id = identifier
    
    # If identifier looks like a phone number
    if identifier.startswith("+") or identifier.startswith("01") or identifier.startswith("880"):
        phone = normalize_phone(identifier)
        user = get_user_account(phone)
        if user:
            account_id = user["account_id"]
    
    # Mock connection lookup
    connection = MOCK_CONNECTIONS.get(account_id)
    
    if connection:
        return connection.copy()
    
    # In production:
    # SELECT * FROM connections WHERE account_id = %s
    
    return None


# ==================== SUPPORT TICKET FUNCTIONS ====================

def create_support_ticket(issue_description: str) -> Optional[Dict]:
    """
    Create a support ticket in the system.
    
    Args:
        issue_description: Detailed description of the issue
        
    Returns:
        Ticket information dictionary
    """
    # Generate ticket ID
    ticket_id = f"TKT{random.randint(100000, 999999)}"
    
    # Determine priority based on keywords
    priority = "Medium"
    if any(word in issue_description.lower() for word in ["urgent", "emergency", "critical"]):
        priority = "High"
    elif any(word in issue_description.lower() for word in ["offline", "no internet", "down"]):
        priority = "High"
    elif any(word in issue_description.lower() for word in ["slow", "billing", "question"]):
        priority = "Low"
    
    # Determine category
    category = "General"
    if "connect" in issue_description.lower() or "internet" in issue_description.lower():
        category = "Connectivity"
    elif "bill" in issue_description.lower() or "payment" in issue_description.lower():
        category = "Billing"
    elif "router" in issue_description.lower() or "hardware" in issue_description.lower():
        category = "Hardware"
    
    # Create ticket object
    ticket = {
        "ticket_id": ticket_id,
        "description": issue_description,
        "priority": priority,
        "category": category,
        "status": "Open",
        "created_at": datetime.now().isoformat(),
        "estimated_resolution": "24-48 hours" if priority != "High" else "4-8 hours"
    }
    
    # In production, save to database:
    # INSERT INTO tickets (ticket_id, description, priority, ...) VALUES (...)
    
    print(f"✓ Created ticket: {ticket_id} | Priority: {priority} | Category: {category}")
    
    return ticket


# ==================== FUTURE DATABASE INTEGRATION ====================

"""
For production, replace mock functions with real database queries:

Example with PostgreSQL (using psycopg2 or SQLAlchemy):

import psycopg2
from app.core.config import settings

def get_db_connection():
    return psycopg2.connect(settings.DATABASE_URL)

def get_user_account(phone: str) -> Optional[Dict]:
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute(
        "SELECT * FROM users WHERE phone = %s",
        (phone,)
    )
    
    result = cursor.fetchone()
    cursor.close()
    conn.close()
    
    if result:
        return {
            "account_id": result[0],
            "name": result[1],
            "phone": result[2],
            # ... map other fields
        }
    
    return None
"""
