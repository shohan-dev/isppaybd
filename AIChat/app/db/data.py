from typing import List, Optional, Dict

# Dummy Data Store for ISP Users
users_db = [
    {
        "user_id": 101,
        "name": "Alice Johnson",
        "plan": "Fiber Ultra 1Gbps",
        "status": "Active",
        "monthly_bill": 89.99,
        "data_usage_gb": 450,
        "address": "123 Maple St, Springfield",
        "last_payment_date": "2023-10-01",
        "issues_reported": []
    },
    {
        "user_id": 102,
        "name": "Bob Smith",
        "plan": "Standard DSL 50Mbps",
        "status": "Active",
        "monthly_bill": 45.00,
        "data_usage_gb": 120,
        "address": "456 Oak Ave, Springfield",
        "last_payment_date": "2023-10-05",
        "issues_reported": ["Slow speeds in evening"]
    },
    {
        "user_id": 103,
        "name": "Charlie Brown",
        "plan": "Fiber Basic 300Mbps",
        "status": "Overdue",
        "monthly_bill": 60.00,
        "data_usage_gb": 310,
        "address": "789 Pine Ln, Springfield",
        "last_payment_date": "2023-09-01",
        "issues_reported": []
    },
    {
        "user_id": 104,
        "name": "Diana Prince",
        "plan": "Fiber Ultra 1Gbps",
        "status": "Active",
        "monthly_bill": 89.99,
        "data_usage_gb": 800,
        "address": "321 Elm St, Metropolis",
        "last_payment_date": "2023-10-02",
        "issues_reported": ["Router reset required"]
    },
    {
        "user_id": 105,
        "name": "Evan Wright",
        "plan": "Cable High Speed 500Mbps",
        "status": "Suspended",
        "monthly_bill": 75.00,
        "data_usage_gb": 0,
        "address": "654 Cedar Dr, Gotham",
        "last_payment_date": "2023-08-15",
        "issues_reported": ["Non-payment"]
    },
    {
        "user_id": 106,
        "name": "Fiona Gallagher",
        "plan": "Standard DSL 50Mbps",
        "status": "Active",
        "monthly_bill": 45.00,
        "data_usage_gb": 45,
        "address": "987 Birch Blvd, Chicago",
        "last_payment_date": "2023-10-10",
        "issues_reported": []
    },
    {
        "user_id": 107,
        "name": "George Martin",
        "plan": "Fiber Basic 300Mbps",
        "status": "Active",
        "monthly_bill": 60.00,
        "data_usage_gb": 290,
        "address": "159 Willow Way, Westeros",
        "last_payment_date": "2023-10-03",
        "issues_reported": ["Intermittent connection"]
    },
    {
        "user_id": 108,
        "name": "Hannah Abbott",
        "plan": "Fiber Ultra 1Gbps",
        "status": "Active",
        "monthly_bill": 89.99,
        "data_usage_gb": 600,
        "address": "753 Hogsmeade Ln, London",
        "last_payment_date": "2023-10-01",
        "issues_reported": []
    },
    {
        "user_id": 109,
        "name": "Ian Malcolm",
        "plan": "Satellite 100Mbps",
        "status": "Active",
        "monthly_bill": 120.00,
        "data_usage_gb": 150,
        "address": "Jurassic Park, Costa Rica",
        "last_payment_date": "2023-10-05",
        "issues_reported": ["High latency"]
    },
    {
        "user_id": 110,
        "name": "Jack Sparrow",
        "plan": "Cable High Speed 500Mbps",
        "status": "Active",
        "monthly_bill": 75.00,
        "data_usage_gb": 400,
        "address": "Black Pearl, Caribbean",
        "last_payment_date": "2023-10-08",
        "issues_reported": []
    }
]

def get_all_users() -> List[Dict]:
    """Returns all user data."""
    return users_db

def get_user_by_id(user_id: int) -> Optional[Dict]:
    """Returns a specific user by ID."""
    for user in users_db:
        if user["user_id"] == user_id:
            return user
    return None

def get_user_by_name(name: str) -> Optional[Dict]:
    """Returns a specific user by Name (case-insensitive partial match)."""
    name_lower = name.lower()
    for user in users_db:
        if name_lower in user["name"].lower():
            return user
    return None
