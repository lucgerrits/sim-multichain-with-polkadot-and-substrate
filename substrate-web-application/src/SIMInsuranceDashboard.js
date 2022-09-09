import React, { useEffect, useState, Fragment } from 'react'
import { Card, Grid, Icon, Label, Statistic, List, Table } from 'semantic-ui-react'
import {
  Link,
} from "react-router-dom";
import { useSubstrateState } from './substrate-lib'

function Main(props) {
  const { api, keyring, socket } = useSubstrateState()

  ////////////////node info
  // const [nodeInfo, setNodeInfo] = useState({})
  // useEffect(() => {
  //   const getInfo = async () => {
  //     try {
  //       const [chain, nodeName, nodeVersion] = await Promise.all([
  //         api.rpc.system.chain(),
  //         api.rpc.system.name(),
  //         api.rpc.system.version(),
  //       ])
  //       setNodeInfo({ chain, nodeName, nodeVersion })
  //     } catch (e) {
  //       console.error(e)
  //     }
  //   }
  //   getInfo()
  // }, [api.rpc.system])
  ////////////////end node info


  ////////////////block info
  // const { finalized } = props
  // const [blockNumber, setBlockNumber] = useState(0)
  // const [blockNumberTimer, setBlockNumberTimer] = useState(0)

  // const bestNumber = finalized
  //   ? api.derive.chain.bestNumberFinalized
  //   : api.derive.chain.bestNumber

  // useEffect(() => {
  //   let unsubscribeAll = null

  //   bestNumber(number => {
  //     // Append `.toLocaleString('en-US')` to display a nice thousand-separated digit.
  //     setBlockNumber(number.toNumber().toLocaleString('en-US'))
  //     setBlockNumberTimer(0)
  //   })
  //     .then(unsub => {
  //       unsubscribeAll = unsub
  //     })
  //     .catch(console.error)

  //   return () => unsubscribeAll && unsubscribeAll()
  // }, [bestNumber])

  // const timer = () => {
  //   setBlockNumberTimer(time => time + 1)
  // }

  // useEffect(() => {
  //   const id = setInterval(timer, 1000)
  //   return () => clearInterval(id)
  // }, [])
  ////////////////end block info

  ////////////////renault info
  const [renaultInfo, setRenaultInfo] = useState({})
  useEffect(() => {
    const getInfo = async () => {
      try {
        const [factories, vehicles, vehiclesStatus] = await Promise.all([
          api.query.palletSimRenault.factories.entries(),
          api.query.palletSimRenault.vehicles.entries(),
          api.query.palletSimRenault.vehiclesStatus.entries(),
        ])
        setRenaultInfo({ factories, vehicles, vehiclesStatus })
      } catch (e) {
        console.error(e)
      }
    }
    getInfo()
  }, [api, api.rpc.state])
  ////////////////end renault info


  function ListFactories() {
    let elements = []
    if (renaultInfo.factories && renaultInfo.factories.length !== 0)
      // some magic to convert the storagekey to actual data:
      renaultInfo.factories.map(([{ args: [vehicleid] }, blocknumber]) => elements.push({ vehicleid: vehicleid, blocknumber: blocknumber }))
    return elements && elements.length !== 0 ? (
      <Fragment>
        {elements.map((element) =>
          <Table.Row key={element.vehicleid.toString()}>
            <Table.Cell><Icon name="warehouse" /> {element.vehicleid.toString()}</Table.Cell>
            <Table.Cell><a href={`https://polkadot.js.org/apps/?rpc=${socket}#/explorer/query/${element.blocknumber.toString()}`} target="_blank"><Icon name="book" /> {element.blocknumber.toString()}</a></Table.Cell>
          </Table.Row>
        )}
      </Fragment>
    ) : (
      <Fragment>
        <Table.Row>
          <Table.Cell>
            <Label basic color="yellow">
              No accounts to be shown
            </Label>
          </Table.Cell>
          <Table.Cell></Table.Cell>
        </Table.Row>
      </Fragment>
    )
  }

  function ListVehicles() {
    let elements = []
    let elements_status = {}
    if (renaultInfo.vehicles && renaultInfo.vehicles.length !== 0)
      // some magic to convert the storagekey to actual data:
      renaultInfo.vehicles.map(([{ args: [vehicleid] }, value]) => {
        elements.push({ vehicleid: vehicleid, factoryid: value.toJSON()[0], blocknumber: value.toJSON()[1] })
      })
    if (renaultInfo.vehiclesStatus && renaultInfo.vehiclesStatus.length !== 0)
      // some magic to convert the storagekey to actual data:
      renaultInfo.vehiclesStatus.map(([{ args: [vehicleid] }, value]) => {
        elements_status[vehicleid] = value.toJSON()
      })
    return elements && elements.length !== 0 ? (
      <Fragment>
        {elements.map((element) =>
          <Table.Row key={element.vehicleid.toString()}>
            <Table.Cell><Icon name="car" /> {element.vehicleid.toString()}</Table.Cell>
            <Table.Cell><Icon name="warehouse" /> {element.factoryid.toString()}</Table.Cell>
            <Table.Cell><a href={`https://polkadot.js.org/apps/?rpc=${socket}#/explorer/query/${element.blocknumber.toString()}`} target="_blank"><Icon name="book" /> {element.blocknumber.toString()}</a></Table.Cell>
            <Table.Cell>{elements_status[element.vehicleid] == true ? "OK" : "KO"}</Table.Cell>
          </Table.Row>
        )}
      </Fragment>
    ) : (
      <Fragment>
        <Table.Row>
          <Table.Cell>
            <Label basic color="yellow">
              No accounts to be shown
            </Label>
          </Table.Cell>
          <Table.Cell></Table.Cell>
          <Table.Cell></Table.Cell>
          <Table.Cell></Table.Cell>
        </Table.Row>
      </Fragment>
    )
  }

  return (
    <Grid.Column>
      <Table celled>
        <Table.Header>
        <Table.Row>
            <Table.HeaderCell colSpan='4'>Insurance Dashboard</Table.HeaderCell>
          </Table.Row>
          <Table.Row>
            <Table.HeaderCell>Factory ID</Table.HeaderCell>
            <Table.HeaderCell>Created at Block Number</Table.HeaderCell>
          </Table.Row>
        </Table.Header>
        <Table.Body>
          <Table.Cell></Table.Cell>
          <Table.Cell></Table.Cell>
          {/* <ListFactories /> */}
        </Table.Body>
      </Table>
    </Grid.Column>
  )
}

export default function SIMInsuranceDashboard(props) {
  const { api } = useSubstrateState()
  return api.query.palletSimRenault &&
    api.rpc &&
    api.rpc.system &&
    api.rpc.system.chain &&
    api.rpc.system.name &&
    api.rpc.system.version &&
    api.derive &&
    api.derive.chain &&
    api.derive.chain.bestNumber &&
    api.derive.chain.bestNumberFinalized ? (
    <Main {...props} />
  ) : null
}
