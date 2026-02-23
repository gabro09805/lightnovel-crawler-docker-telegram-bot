"""Add UserToken

Revision ID: a9c3a37c3cf1
Revises: 2c1b5463eecb
Create Date: 2026-02-23 19:57:44.672891
"""

from typing import Sequence, Union

import sqlmodel as sa
from alembic import op
from sqlmodel.sql.sqltypes import AutoString

# revision identifiers, used by Alembic.
revision: str = "a9c3a37c3cf1"
down_revision: Union[str, Sequence[str], None] = "2c1b5463eecb"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

try:
    dialect = op.get_context().dialect.name
except Exception:
    dialect = ""


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        "user_tokens",
        sa.Column("token", sa.CHAR(10), nullable=False),
        sa.Column("user_id", AutoString(), nullable=False),
        sa.Column("expires_at", sa.BigInteger(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("token"),
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_table("user_tokens")
