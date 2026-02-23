from typing import Optional

import sqlmodel as sa

from ..utils.crypto_tools import generate_token
from ..utils.time_utils import current_timestamp
from ._base import BaseTable
from .enums import UserRole, UserTier


class User(BaseTable, table=True):
    __tablename__ = 'users'  # type: ignore

    referrer_id: Optional[str] = sa.Field(
        default=None,
        foreign_key="users.id",
        ondelete='SET NULL',
        nullable=True,
    )

    password: str = sa.Field(
        description="Hashed password",
        exclude=True
    )
    email: str = sa.Field(
        unique=True,
        index=True,
        description="User Email"
    )
    name: Optional[str] = sa.Field(
        default=None,
        description="Full name"
    )
    role: UserRole = sa.Field(
        default=UserRole.USER,
        description="User role"
    )
    tier: UserTier = sa.Field(
        default=UserTier.BASIC,
        description="User tier"
    )
    is_active: bool = sa.Field(
        default=True,
        description="Active status"
    )


class VerifiedEmail(sa.SQLModel, table=True):
    email: str = sa.Field(
        primary_key=True,
        description="User Email"
    )
    created_at: int = sa.Field(
        sa_type=sa.BigInteger,
        default_factory=current_timestamp
    )


class UserToken(sa.SQLModel, table=True):
    __tablename__ = 'user_tokens'  # type: ignore

    token: str = sa.Field(
        default_factory=generate_token,
        sa_column=sa.Column(sa.CHAR(10), primary_key=True, nullable=False)
    )
    user_id: str = sa.Field(
        foreign_key="users.id",
        ondelete='CASCADE'
    )
    expires_at: int = sa.Field(
        sa_type=sa.BigInteger,
        nullable=False
    )
