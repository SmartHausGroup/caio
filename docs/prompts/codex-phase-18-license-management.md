# CAIO Phase 18: License Management System Implementation Plan

**Status:** Ready for Execution  
**Date:** 2026-01-12  
**Owner:** Codex  
**Plan Reference:** `plan:EXECUTION_PLAN:18`

---

## Executive Summary

Create a license management system that allows SmartHaus to generate, distribute, track, and manage CAIO licenses for on-premises customers. This system can start as a rudimentary in-house solution (SQLite database, simple scripts) and scale to a more sophisticated system or third-party integration later.

**Key Deliverables:**
1. License generation system (generate license keys for customers)
2. License distribution (distribute licenses to customers)
3. License tracking (track license usage and status)
4. License management UI (optional, can start simple with Streamlit or CLI)
5. License analytics (optional, basic analytics)
6. Integration with Phase 17 (connect to on-premises licensing system)

**Estimated Time:** 1-2 weeks  
**Priority:** High (enables on-premises business model)

**CRITICAL:** This can start as a simple in-house system (SQLite database, basic Python scripts) and evolve to a more sophisticated solution or third-party integration later. Start simple to avoid initial costs.

---

## Context & Background

### Current State

- ✅ **CAIO Core:** Fully implemented and production-ready (Phases 0-17 complete)
- ✅ **On-Premises Licensing:** License key system and validation implemented (Phase 17)
- ❌ **License Management:** No license management system exists
- ❌ **License Generation:** No system for generating licenses
- ❌ **License Distribution:** No system for distributing licenses
- ❌ **License Tracking:** No system for tracking licenses

### North Star Alignment

This task directly supports the CAIO North Star by:

- **Business Model:** Enables on-premises licensing revenue stream
- **Universal Compatibility:** License management enables CAIO in any environment
- **Mathematical Guarantees:** License tracking ensures guarantees are preserved
- **Security Built into Math:** License management enhances security model

**Reference:** `docs/NORTH_STAR.md` - Universal AI orchestration platform

### Execution Plan Reference

This task implements Phase 18: License Management System from `docs/operations/EXECUTION_PLAN.md`:

- **18.1:** Create license generation system
- **18.2:** Create license distribution system
- **18.3:** Create license tracking system
- **18.4:** Create license management UI (optional)
- **18.5:** Integrate with Phase 17
- **18.6:** Create documentation

---

## Step-by-Step Implementation Instructions

### Task 18.1: Create License Generation System

**Objective:** Create system for generating license keys.

#### Step 1.1: Create Customer Database

**File:** `caio/licensing/database.py`

**Database Schema (SQLite for simplicity):**
```python
import sqlite3
from pathlib import Path
from typing import Optional, List, Dict, Any
from datetime import datetime

class LicenseDatabase:
    def __init__(self, db_path: Path = Path("caio_licenses.db")):
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        """Initialize database schema."""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Customers table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS customers (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                email TEXT,
                company TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Licenses table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS licenses (
                id TEXT PRIMARY KEY,
                customer_id TEXT NOT NULL,
                license_key TEXT UNIQUE NOT NULL,
                license_type TEXT NOT NULL,
                issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                expires_at TIMESTAMP,
                features TEXT,  -- JSON array
                max_instances INTEGER,
                max_services INTEGER,
                max_requests_per_day INTEGER,
                status TEXT DEFAULT 'active',
                FOREIGN KEY (customer_id) REFERENCES customers(id)
            )
        """)
        
        # License activations table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS license_activations (
                id TEXT PRIMARY KEY,
                license_id TEXT NOT NULL,
                activated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                instance_id TEXT,
                ip_address TEXT,
                FOREIGN KEY (license_id) REFERENCES licenses(id)
            )
        """)
        
        conn.commit()
        conn.close()
    
    def create_customer(self, customer_id: str, name: str, email: Optional[str] = None, company: Optional[str] = None) -> bool:
        """Create a new customer."""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute("""
                INSERT INTO customers (id, name, email, company)
                VALUES (?, ?, ?, ?)
            """, (customer_id, name, email, company))
            conn.commit()
            return True
        except sqlite3.IntegrityError:
            return False
        finally:
            conn.close()
    
    def create_license(self, license_data: Dict[str, Any]) -> bool:
        """Create a new license record."""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute("""
                INSERT INTO licenses (
                    id, customer_id, license_key, license_type, expires_at,
                    features, max_instances, max_services, max_requests_per_day
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                license_data["id"],
                license_data["customer_id"],
                license_data["license_key"],
                license_data["license_type"],
                license_data.get("expires_at"),
                json.dumps(license_data.get("features", [])),
                license_data.get("max_instances"),
                license_data.get("max_services"),
                license_data.get("max_requests_per_day"),
            ))
            conn.commit()
            return True
        except sqlite3.IntegrityError:
            return False
        finally:
            conn.close()
    
    def get_license(self, license_key: str) -> Optional[Dict[str, Any]]:
        """Get license by license key."""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute("SELECT * FROM licenses WHERE license_key = ?", (license_key,))
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return dict(row)
        return None
    
    def list_licenses(self, customer_id: Optional[str] = None) -> List[Dict[str, Any]]:
        """List licenses, optionally filtered by customer."""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        if customer_id:
            cursor.execute("SELECT * FROM licenses WHERE customer_id = ?", (customer_id,))
        else:
            cursor.execute("SELECT * FROM licenses")
        
        rows = cursor.fetchall()
        conn.close()
        
        return [dict(row) for row in rows]
```

#### Step 1.2: Create License Generation Service

**File:** `caio/licensing/generation_service.py`

**Generation Service:**
```python
from caio.licensing.generator import LicenseKeyGenerator
from caio.licensing.database import LicenseDatabase
from caio.licensing.schema import LicenseMetadata, LicenseType
from datetime import datetime, timedelta
from typing import Optional, List
import uuid

class LicenseGenerationService:
    def __init__(self, secret_key: str, db_path: Path = Path("caio_licenses.db")):
        self.generator = LicenseKeyGenerator(secret_key)
        self.db = LicenseDatabase(db_path)
    
    def generate_license(
        self,
        customer_id: str,
        license_type: LicenseType,
        expires_days: Optional[int] = None,
        features: Optional[List[str]] = None,
        max_instances: Optional[int] = None,
        max_services: Optional[int] = None,
        max_requests_per_day: Optional[int] = None,
    ) -> str:
        """Generate license key for customer."""
        # Create license metadata
        expires_at = None
        if expires_days:
            expires_at = datetime.now() + timedelta(days=expires_days)
        
        metadata = LicenseMetadata(
            customer_id=customer_id,
            license_type=license_type,
            issued_at=datetime.now(),
            expires_at=expires_at,
            features=features or [],
            max_instances=max_instances,
            max_services=max_services,
            max_requests_per_day=max_requests_per_day,
        )
        
        # Generate license key
        license_key = self.generator.generate_license_key(metadata)
        
        # Store in database
        license_id = str(uuid.uuid4())
        self.db.create_license({
            "id": license_id,
            "customer_id": customer_id,
            "license_key": license_key,
            "license_type": license_type.value,
            "expires_at": expires_at,
            "features": features or [],
            "max_instances": max_instances,
            "max_services": max_services,
            "max_requests_per_day": max_requests_per_day,
        })
        
        return license_key
    
    def export_licenses(self, customer_id: Optional[str] = None, format: str = "csv") -> str:
        """Export licenses to CSV or JSON."""
        licenses = self.db.list_licenses(customer_id)
        
        if format == "csv":
            import csv
            from io import StringIO
            
            output = StringIO()
            writer = csv.DictWriter(output, fieldnames=["id", "customer_id", "license_key", "license_type", "expires_at", "status"])
            writer.writeheader()
            for license in licenses:
                writer.writerow(license)
            return output.getvalue()
        else:  # JSON
            import json
            return json.dumps(licenses, indent=2, default=str)
```

**Validation:**
- Customer database created
- License generation service implemented
- License export functional

---

### Task 18.2: Create License Distribution System

**Objective:** Create system for distributing licenses to customers.

#### Step 2.1: Create License Delivery System

**File:** `caio/licensing/distribution.py`

**Distribution Service:**
```python
from caio.licensing.generation_service import LicenseGenerationService
from typing import Optional
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

class LicenseDistributionService:
    def __init__(self, generation_service: LicenseGenerationService):
        self.generation_service = generation_service
    
    def distribute_license(
        self,
        customer_id: str,
        customer_email: str,
        license_type: LicenseType,
        expires_days: Optional[int] = None,
        send_email: bool = False,
    ) -> str:
        """Generate and distribute license to customer."""
        # Generate license
        license_key = self.generation_service.generate_license(
            customer_id=customer_id,
            license_type=license_type,
            expires_days=expires_days,
        )
        
        # Send email (optional)
        if send_email:
            self.send_license_email(customer_email, license_key, license_type, expires_days)
        
        return license_key
    
    def send_license_email(
        self,
        email: str,
        license_key: str,
        license_type: LicenseType,
        expires_days: Optional[int],
    ):
        """Send license key via email (optional, can be disabled)."""
        # Email configuration from environment
        smtp_server = os.getenv("SMTP_SERVER")
        smtp_port = int(os.getenv("SMTP_PORT", "587"))
        smtp_user = os.getenv("SMTP_USER")
        smtp_password = os.getenv("SMTP_PASSWORD")
        
        if not all([smtp_server, smtp_user, smtp_password]):
            # Email not configured, skip
            return
        
        msg = MIMEMultipart()
        msg["From"] = smtp_user
        msg["To"] = email
        msg["Subject"] = "CAIO License Key"
        
        body = f"""
        Your CAIO license key has been generated.
        
        License Type: {license_type.value}
        Expires: {expires_days} days from now (if applicable)
        
        License Key:
        {license_key}
        
        Please keep this license key secure.
        """
        
        msg.attach(MIMEText(body, "plain"))
        
        try:
            server = smtplib.SMTP(smtp_server, smtp_port)
            server.starttls()
            server.login(smtp_user, smtp_password)
            server.send_message(msg)
            server.quit()
        except Exception as e:
            # Log error, but don't fail
            print(f"Failed to send email: {e}")
```

**Validation:**
- License distribution service created
- Email distribution working (optional)
- License delivery functional

---

### Task 18.3: Create License Tracking System

**Objective:** Track license status and usage.

#### Step 3.1: Create License Tracking Service

**File:** `caio/licensing/tracking.py`

**Tracking Service:**
```python
from caio.licensing.database import LicenseDatabase
from datetime import datetime
from typing import List, Dict, Any

class LicenseTrackingService:
    def __init__(self, db_path: Path = Path("caio_licenses.db")):
        self.db = LicenseDatabase(db_path)
    
    def track_activation(self, license_key: str, instance_id: str, ip_address: Optional[str] = None):
        """Track license activation."""
        license = self.db.get_license(license_key)
        if not license:
            return False
        
        activation_id = str(uuid.uuid4())
        conn = sqlite3.connect(self.db.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT INTO license_activations (id, license_id, instance_id, ip_address)
            VALUES (?, ?, ?, ?)
        """, (activation_id, license["id"], instance_id, ip_address))
        
        conn.commit()
        conn.close()
        return True
    
    def get_expiring_licenses(self, days: int = 30) -> List[Dict[str, Any]]:
        """Get licenses expiring within N days."""
        conn = sqlite3.connect(self.db.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cutoff_date = datetime.now() + timedelta(days=days)
        cursor.execute("""
            SELECT * FROM licenses
            WHERE expires_at IS NOT NULL
            AND expires_at <= ?
            AND status = 'active'
        """, (cutoff_date,))
        
        rows = cursor.fetchall()
        conn.close()
        
        return [dict(row) for row in rows]
    
    def get_license_statistics(self) -> Dict[str, Any]:
        """Get license statistics."""
        conn = sqlite3.connect(self.db.db_path)
        cursor = conn.cursor()
        
        # Total licenses
        cursor.execute("SELECT COUNT(*) FROM licenses")
        total = cursor.fetchone()[0]
        
        # Active licenses
        cursor.execute("SELECT COUNT(*) FROM licenses WHERE status = 'active'")
        active = cursor.fetchone()[0]
        
        # Expired licenses
        cursor.execute("""
            SELECT COUNT(*) FROM licenses
            WHERE expires_at IS NOT NULL AND expires_at < ?
        """, (datetime.now(),))
        expired = cursor.fetchone()[0]
        
        conn.close()
        
        return {
            "total": total,
            "active": active,
            "expired": expired,
            "expiring_soon": len(self.get_expiring_licenses(30)),
        }
```

**Validation:**
- License tracking service created
- Activation tracking working
- Expiration monitoring working
- Statistics working

---

### Task 18.4: Create License Management UI (Optional)

**Objective:** Create web interface for managing licenses (can start simple).

#### Step 4.1: Create Streamlit UI

**File:** `caio/licensing/ui.py` or `scripts/licensing/manage_licenses.py`

**Simple CLI or Streamlit UI:**
```python
import streamlit as st
from caio.licensing.generation_service import LicenseGenerationService
from caio.licensing.tracking import LicenseTrackingService
from caio.licensing.schema import LicenseType

st.title("CAIO License Management")

# License generation
st.header("Generate License")
customer_id = st.text_input("Customer ID")
license_type = st.selectbox("License Type", [t.value for t in LicenseType])
expires_days = st.number_input("Expires (days)", min_value=1, value=365)

if st.button("Generate License"):
    service = LicenseGenerationService(secret_key=st.secrets["CAIO_LICENSE_SECRET"])
    license_key = service.generate_license(
        customer_id=customer_id,
        license_type=LicenseType(license_type),
        expires_days=expires_days,
    )
    st.success(f"License generated: {license_key}")

# License list
st.header("Licenses")
tracking = LicenseTrackingService()
licenses = tracking.db.list_licenses()
st.dataframe(licenses)

# Statistics
st.header("Statistics")
stats = tracking.get_license_statistics()
st.json(stats)
```

**Validation:**
- License management UI created (simple version)
- License generation form working
- License list view working
- Statistics view working

---

### Task 18.5: Integrate with Phase 17

**Objective:** Connect license management to on-premises licensing.

#### Step 5.1: Create License Activation Tracking

**File:** `caio/api/routes/licensing.py` (update)

**Add Activation Tracking:**
```python
from caio.licensing.tracking import LicenseTrackingService

@router.post("/activate", response_model=LicenseActivationResponse)
async def activate_license(
    request: LicenseActivationRequest,
    validator: LicenseValidator = Depends(get_license_validator),
    tracking: LicenseTrackingService = Depends(get_license_tracking),
):
    """Activate license key and track activation."""
    is_valid, error = validator.load_license(request.license_key)
    if not is_valid:
        raise HTTPException(status_code=400, detail=error or "Invalid license")
    
    # Track activation
    tracking.track_activation(
        license_key=request.license_key,
        instance_id=request.instance_id,
        ip_address=request.client.host,
    )
    
    return LicenseActivationResponse(
        status="activated",
        customer_id=validator.license_metadata.customer_id,
        expires_at=validator.license_metadata.expires_at,
    )
```

**Validation:**
- Integration with Phase 17 complete
- Activation tracking working
- License status synchronized

---

### Task 18.6: Create Documentation

**Objective:** Document license management system.

#### Step 6.1: Create License Management Guide

**File:** `docs/licensing/LICENSE_MANAGEMENT.md`

**Sections:**
1. Overview
2. Generating Licenses
3. Distributing Licenses
4. Tracking Licenses
5. License Management UI
6. Troubleshooting

**Validation:**
- Documentation complete
- Guides functional
- Examples provided

---

## Validation Procedures

### License Generation Test

**Commands:**
```bash
python -c "
from caio.licensing.generation_service import LicenseGenerationService
from caio.licensing.schema import LicenseType

service = LicenseGenerationService(secret_key='test-secret')
key = service.generate_license(
    customer_id='CUST123',
    license_type=LicenseType.STANDARD,
    expires_days=365,
)
print(f'Generated: {key}')
"
```

### License Tracking Test

**Commands:**
```bash
python -c "
from caio.licensing.tracking import LicenseTrackingService

tracking = LicenseTrackingService()
stats = tracking.get_license_statistics()
print(f'Statistics: {stats}')
"
```

---

## Success Criteria

**License Management:**
- [ ] License generation system functional
- [ ] License distribution working
- [ ] License tracking working
- [ ] License management UI functional (if implemented)
- [ ] Integration with Phase 17 working
- [ ] Documentation complete

---

## Risks and Mitigation

**Risk 1: System complexity**
- **Mitigation:** Start simple (SQLite, scripts)
- **Mitigation:** Can evolve to sophisticated solution later

**Risk 2: License key security**
- **Mitigation:** Use same cryptographic system as Phase 17
- **Mitigation:** Secure storage of secret keys

**Risk 3: Scalability**
- **Mitigation:** Start with SQLite, can migrate to PostgreSQL later
- **Mitigation:** Design for future migration

---

## Notes and References

- **Phase 17 Plan:** `plans/phase-17-on-premises-licensing/`
- **SQLite Documentation:** https://docs.python.org/3/library/sqlite3.html
- **Streamlit Documentation:** https://docs.streamlit.io/

---

**Last Updated:** 2026-01-12
**Version:** 1.0
