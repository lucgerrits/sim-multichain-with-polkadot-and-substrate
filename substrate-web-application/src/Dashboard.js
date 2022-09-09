import React from 'react'
import {
  Container,
  Grid
} from 'semantic-ui-react'
import 'semantic-ui-css/semantic.min.css'

import { useSubstrateState } from './substrate-lib'
import { DeveloperConsole } from './substrate-lib/components'

import SIMRenaultDashboard from './SIMRenaultDashboard'
import SIMInsuranceDashboard from './SIMInsuranceDashboard'
import NotConnected from './NotConnected'

function Main(props) {

  return (
    <div>
      <Container>
        <Grid stackable columns="equal">
          <Grid.Row stretched>
            <SIMRenaultDashboard />
          </Grid.Row>
          <Grid.Row stretched>
            <SIMInsuranceDashboard />
          </Grid.Row>
        </Grid>
      </Container>
      <DeveloperConsole />
    </div>
  )
}

export default function Dashboard(props) {
    const { api } = useSubstrateState()
    return api.rpc && api.rpc.state ? (
        <Main {...props} />
    ) : <NotConnected />
  }
  