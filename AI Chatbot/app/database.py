"""
Database Layer
Real SQLite database implementation using SQLAlchemy.
"""

from typing import Dict, Optional, List
from datetime import datetime
import json
import random
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from .models import Base, User, Ticket, Connection

# ==================== DATABASE SETUP ====================

SQLALCHEMY_DATABASE_URL = "sqlite:///./isp_chatbot.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ==================== INITIALIZATION ====================

def init_db():
    """Initialize database with tables and seed data if empty."""
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    if db.query(User).count() == 0:
        print("🌱 Seeding database with initial data...")
        
        # Seed Users
        users_data = [
            {
                "phone": "+8801712345678",
                "name": "Ahmed Hassan",
                "plan": "100 Mbps Unlimited",
                "status": "Active",
                "balance": 0.0,
                "address": "Dhaka, Bangladesh"
            },
            {
                "phone": "+8801823456789",
                "name": "Fatima Rahman",
                "plan": "50 Mbps Standard",
                "status": "Active",
                "balance": -500.0,
                "address": "Chittagong, Bangladesh"
            },
            {
                "phone": "+8801534567890",
                "name": "Karim Ahmed",
                "plan": "200 Mbps Premium",
                "status": "Suspended",
                "balance": -1200.0,
                "address": "Sylhet, Bangladesh"
            }
        ]
        
        for u_data in users_data:
            user = User(**u_data)
            db.add(user)
            db.commit()
            db.refresh(user)
            
            # Seed Connection for this user
            if user.phone == "+8801712345678":
                conn = Connection(
                    user_id=user.id,
                    is_online=1,
                    router_status="Connected",
                    signal_strength="Excellent (95%)",
                    last_online="Currently Online",
                    uptime="15 days, 6 hours",
                    download_speed=98.5,
                    upload_speed=95.2,
                    issues="[]"
                )
            elif user.phone == "+8801823456789":
                conn = Connection(
                    user_id=user.id,
                    is_online=0,
                    router_status="Disconnected",
                    signal_strength="Poor (20%)",
                    last_online="2 hours ago",
                    uptime="0 days, 0 hours",
                    download_speed=0.0,
                    upload_speed=0.0,
                    issues=json.dumps(["Router offline", "No signal detected", "Possible cable damage"])
                )
            else:
                conn = Connection(
                    user_id=user.id,
                    is_online=0,
                    router_status="Suspended",
                    signal_strength="N/A",
                    last_online="5 days ago",
                    uptime="0 days, 0 hours",
                    download_speed=0.0,
                    upload_speed=0.0,
                    issues=json.dumps(["Account suspended due to unpaid balance"])
                )
            db.add(conn)
        
        db.commit()
        print("✅ Database seeded successfully.")
    
    db.close()

# Initialize DB on module import (or call explicitly in main.py)
init_db()

# ==================== HELPER FUNCTIONS ====================

def normalize_phone(phone: str) -> str:
    """
    Normalize phone number to consistent format.
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

# ==================== USER ACCOUNT FUNCTIONS ====================

def get_user_account(phone: str) -> Optional[Dict]:
    """
    Retrieve user account information by phone number.
    """
    phone = normalize_phone(phone)
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.phone == phone).first()
        if user:
            return {
                "account_id": f"USR{user.id:03d}",
                "name": user.name,
                "phone": user.phone,
                "plan": user.plan,
                "status": user.status,
                "balance": user.balance,
                "address": user.address
            }
        return None
    finally:
        db.close()

# ==================== CONNECTION STATUS FUNCTIONS ====================

def check_connection_status(identifier: str) -> Optional[Dict]:
    """
    Check internet connection status for a user.
    """
    db = SessionLocal()
    try:
        # Try to find user first
        user = None
        if identifier.startswith("+") or identifier.startswith("01") or identifier.startswith("880"):
            phone = normalize_phone(identifier)
            user = db.query(User).filter(User.phone == phone).first()
        
        if not user:
            # Try by account ID (USR001)
            if identifier.startswith("USR"):
                try:
                    uid = int(identifier.replace("USR", ""))
                    user = db.query(User).filter(User.id == uid).first()
                except:
                    pass
        
        if user and user.connection:
            conn = user.connection
            return {
                "is_online": bool(conn.is_online),
                "router_status": conn.router_status,
                "signal_strength": conn.signal_strength,
                "last_online": conn.last_online,
                "uptime": conn.uptime,
                "download_speed": conn.download_speed,
                "upload_speed": conn.upload_speed,
                "issues": json.loads(conn.issues) if conn.issues else []
            }
        
        return None
    finally:
        db.close()

# ==================== SUPPORT TICKET FUNCTIONS ====================

def create_support_ticket(issue_description: str) -> Optional[Dict]:
    """
    Create a support ticket in the system.
    """
    db = SessionLocal()
    try:
        # Determine priority based on keywords
        priority = "Medium"
        desc_lower = issue_description.lower()
        if any(word in desc_lower for word in ["urgent", "emergency", "critical"]):
            priority = "High"
        elif any(word in desc_lower for word in ["offline", "no internet", "down"]):
            priority = "High"
        elif any(word in desc_lower for word in ["slow", "billing", "question"]):
            priority = "Low"
        
        # Determine category
        category = "General"
        if "connect" in desc_lower or "internet" in desc_lower:
            category = "Connectivity"
        elif "bill" in desc_lower or "payment" in desc_lower:
            category = "Billing"
        elif "router" in desc_lower or "hardware" in desc_lower:
            category = "Hardware"
        
        # Try to extract phone number to link user
        user_id = None
        import re
        phone_match = re.search(r"(\+880\d{10}|01\d{9})", issue_description)
        if phone_match:
            phone = normalize_phone(phone_match.group(1))
            user = db.query(User).filter(User.phone == phone).first()
            if user:
                user_id = user.id

        ticket = Ticket(
            user_id=user_id,
            issue=issue_description,
            priority=priority,
            status="Open",
            created_at=datetime.utcnow()
        )
        db.add(ticket)
        db.commit()
        db.refresh(ticket)
        
        return {
            "ticket_id": f"TKT{ticket.id:06d}",
            "description": ticket.issue,
            "priority": ticket.priority,
            "category": category,
            "status": ticket.status,
            "created_at": ticket.created_at.isoformat(),
            "estimated_resolution": "24-48 hours" if priority != "High" else "4-8 hours"
        }
    except Exception as e:
        print(f"Error creating ticket: {e}")
        return None
    finally:
        db.close()
