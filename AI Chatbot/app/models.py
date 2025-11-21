from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, create_engine
from sqlalchemy.orm import declarative_base, relationship
from datetime import datetime

Base = declarative_base()

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String, unique=True, index=True)
    name = Column(String)
    plan = Column(String)
    balance = Column(Float, default=0.0)
    status = Column(String, default="active")  # active, suspended, inactive
    address = Column(String)
    
    tickets = relationship("Ticket", back_populates="user")
    connection = relationship("Connection", back_populates="user", uselist=False)

class Connection(Base):
    __tablename__ = "connections"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True)
    is_online = Column(Integer, default=1) # 1 for True, 0 for False
    router_status = Column(String)
    signal_strength = Column(String)
    last_online = Column(String)
    uptime = Column(String)
    download_speed = Column(Float)
    upload_speed = Column(Float)
    issues = Column(String) # JSON string or comma separated

    user = relationship("User", back_populates="connection")

class Ticket(Base):
    __tablename__ = "tickets"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    issue = Column(String)
    status = Column(String, default="open")  # open, in_progress, resolved, closed
    priority = Column(String, default="medium")
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="tickets")
